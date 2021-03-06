# frozen_string_literal: true

require 'sinatra'
require 'sinatra/content_for'
require 'tilt/erubis'
require 'bcrypt'

require_relative 'database_persistence'

configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, escape_html: true
end

configure(:development) do 
  require 'sinatra/reloader'
  also_reload 'database_persistence.rb'
end

helpers do 
  def convert_param_crop_name(name)
    name.split('_').map(&:capitalize).join(' ')
  end

  def convert_crop_name_img(name)
    name.gsub(' ', '_')
  end

  def convert_num_to_season(num)
    case num
    when 1 then 'Spring'
    when 2 then 'Summer'
    when 3 then 'Fall'
    end
  end

  def convert_season_to_num(season)
    case season 
    when 'spring' then 1
    when 'summer' then 2
    when 'fall' then 3
    end
  end

  def convert_crop_name_with_space(name)
    name.split(' ').join('_')
  end

  def convert_number_to_string(num)
    return '0' if num.nil? || num.zero?
    num.to_s.reverse.scan(/\d{1,3}/).join(',').reverse
  end

  def create_array_of_crop_values(tuple)
    tuple.values
  end

  def reject_non_season_crops(crops)
    curr_season_int = nil
    case @season 
    when 'Spring' then curr_season_int = 1
    when 'Summer' then curr_season_int = 2
    when 'Fall' then curr_season_int = 3
    end

    crops.reject! { |tuple| tuple[:season] != curr_season_int }
  end

  def all_planted_crops_in_season
    @storage.all_planted_crops(@user_id.to_i).select do |tuple|
      convert_num_to_season(tuple[:season_id]) == @season
    end
  end

  def available_planting_days
    days_with_harvests = @planted_crops.map do |tuple| 
                           if convert_num_to_season(tuple[:season_id]) == @season
                            (tuple[:sub_harvests] + [tuple[:first_harvest]]).flatten
                           end
                         end.flatten

    days_with_harvests.select do |int|
      days_with_harvests.count(int) >= 4
    end

    (1..28).to_a.reject { |int| days_with_harvests.include?(int) }
  end

  def return_crop_name(id)
    @storage.single_crop_by_id(id)[:name]
  end

  def return_crop_name_reduce_name(id)
    name = @storage.single_crop_by_id(id)[:name]
    name.length > 6 ? name[0...5] + '...' : name
  end

  def return_crop_id(name)
    @storage.single_crop(name)[:id]
  end

  def return_crop_profit(id, amount)
    sell_price = @storage.prices_single_crop(id)[0][:sell_price]
    amount_per_pick = @storage.single_crop_by_id(id)[:produces]
    sell_price * amount_per_pick * amount
  end

  def return_seed_cost(id, amount)
    seed_price = @storage.prices_single_crop(id)[0][:seed_price]
    seed_price * amount
  end

  def return_total_crop_gross
    return 0 if @planted_crops.size.zero?

    total = 0

    @planted_crops.each do |t| 
      gross = (return_crop_profit(t[:crop_id], t[:amount_planted]))
      if !t[:first_harvest].zero? && !t[:sub_harvests][0].zero?
        gross *= t[:sub_harvests].size + 1
      elsif t[:first_harvest].zero?
        gross = 0
      end
      total += gross
    end
    
    total
  end

  def return_total_seed_cost
    return 0 if @planted_crops.size.zero?

    @planted_crops.map do |t|
      return_seed_cost(t[:crop_id], t[:amount_planted])
    end.reduce(:+)
  end

  def return_total_profit
    convert_number_to_string(return_total_crop_gross - 
                             return_total_seed_cost )
  end

  def return_season_id(name)
    @storage.single_crop(name)[:season]
  end

  def return_first_harvest(name, date)
    days = @storage.single_crop(name)[:until_harvest]
    first_harvest = days + date 
    first_harvest > 28 ? 0 : first_harvest
  end

  def return_sub_harvests(name, first_harvest)
    regrow_int = @storage.single_crop(name)[:regrow]
    return 0 if regrow_int.zero? || first_harvest.zero?

    sub_harvests = []

    until first_harvest >= 28
      first_harvest += regrow_int

      if first_harvest <= 28
        sub_harvests << first_harvest
      else
        break
      end
    end

    sub_harvests
  end

  def convert_sub_harvests_string(sub_harvests)
    return "{NULL}" if sub_harvests[0].zero?
    str = ""
    sub_harvests.each { |num| str += "#{num}, " }
    2.times { str[-1] = "" }
    str.prepend("{")
    str += "}"
  end

  def add_planted_crop_to_db(str)
    @storage.add_planted_crop(str)
  end

  def remove_single_crop(id, user_id)
    @storage.delete_single_planted_crop(id, user_id)
  end

  def remove_all_crops(season, user_id)
    @storage.delete_all_planted_crops_from_season(season, user_id)
  end

  def display_before_season
    case @season
    when 'Spring' then 'Fall'
    when 'Summer' then 'Spring'
    when 'Fall' then 'Summer'
    end
  end

  def display_after_season
    case @season
    when 'Spring' then 'Summer'
    when 'Summer' then 'Fall'
    when 'Fall' then 'Spring'
    end
  end

  def user_doesnt_exist?(username)
    return true if @storage.load_user_by_name(username).empty?
    false
  end

  def add_user_to_db(username, pw)
    @storage.add_user_to_database(username, pw)
  end

  def user_valid?(username, pw)
    creds = @storage.load_user_by_name(username)
    return false if creds.empty?

    if creds[0][:name] == username
      BCrypt::Password.new(creds[0][:password]) == pw
    else
      false
    end
  end

  def return_user_id
    @storage.load_user_id_by_name(session[:curr_user])
  end

  def logged_in?
    redirect "/login" if session[:curr_user].nil?
  end
end

before do
  @storage = DatabasePersistence.new(logger)
end

after do
  @storage.disconnect
end

get "/" do
  erb :index
end

get "/crops/selection" do 
  @current_crop = @storage.single_crop(params[:crop_name])
  @prices = @storage.prices_single_crop(@current_crop[:id])[0]
  @img_name = convert_crop_name_img(params[:crop_name])
  erb :single_crop
end

get "/calendar/:season" do
  logged_in?
  @user_id = return_user_id
  @season = params[:season].capitalize
  @seasons = ["Spring", "Summer", "Fall"]
  @planted_crops = all_planted_crops_in_season
  @calendar_days = (1..28).to_a
  @crops = reject_non_season_crops(@storage.all_crops)
  @profit = return_total_profit
  
  erb :calendar
end

get "/crop_directory" do
  @crops = @storage.all_crops
  erb :crop_directory
end

get "/login" do
  erb :login
end

post "/login" do 
  if user_valid?(params[:username], params[:password])
    session[:curr_user] = params[:username]
    redirect "/calendar/spring"
  else
    session[:login_error] = "Invalid credentials."
    redirect "/login"
  end
end

post "/register" do
  if user_doesnt_exist?(params[:username])
    add_user_to_db(params[:username],
                   BCrypt::Password.create(params[:password])
                   )
    session[:register_success] = "User created."
  else
    session[:register_error] = "Username is unavailable."

  end
  redirect "/login"
end

post "/logout" do
  session.delete(:curr_user)
  redirect "/"
end

post "/add_crop_calendar" do 
  param_hash = { crop: params["crop_name"],
                 plant_date: params["plant_date"].to_i,
                 amount: params["amount_planted"].to_i }

  crop_id = return_crop_id(param_hash[:crop])
  season_id = return_season_id(param_hash[:crop])
  season = convert_num_to_season(season_id)
  first_harvest = return_first_harvest(param_hash[:crop], param_hash[:plant_date])
  sub_harvest_array = return_sub_harvests(param_hash[:crop], first_harvest)
  user_id = return_user_id

  values = [crop_id, 
            season_id, 
            param_hash[:plant_date],
            first_harvest, 
            convert_sub_harvests_string(sub_harvest_array),
            param_hash[:amount],
            user_id ]

  add_planted_crop_to_db(values)
  redirect "/calendar/#{season.downcase}"
end

post "/:season/delete_single_crop" do
  id = params[:id]
  user_id = return_user_id

  remove_single_crop(id, user_id)
  redirect "/calendar/#{params[:season]}"
end

post "/:season/delete_season_crops" do
  user_id = return_user_id
  season = convert_season_to_num(params[:season].downcase)
  remove_all_crops(season, user_id)
  redirect "/calendar/#{params[:season]}"
end

post "/delete_user" do 
  @storage.delete_user_by_name(params[:name])
  redirect "/"
end
