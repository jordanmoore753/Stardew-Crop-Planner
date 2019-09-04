require "sinatra"
require "sinatra/content_for"
require "tilt/erubis"

require_relative "database_persistence"

configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end

configure(:development) do 
  require "sinatra/reloader"
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
		when 1 then "Spring"
		when 2 then "Summer"
		when 3 then "Fall"
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
		@storage.all_planted_crops.select do |tuple|
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

	def return_crop_id(name)
		@storage.single_crop(name)[:id]
	end

	def return_crop_profit(id, amount)
		sell_price = @storage.prices_single_crop(id)[0][:sell_price]
		amount_per_pick = @storage.single_crop_by_id(id)[:produces]
		sell_price * amount_per_pick * amount
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
		return 0 if regrow_int.zero?

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
		2.times { str[-1] = '' }
		str.prepend("{")
		str += "}"
	end

	def add_planted_crop_to_db(str)
		@storage.add_planted_crop(str)
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
	@season = params[:season].capitalize
	@seasons = ["Spring", "Summer", "Fall"]
	@planted_crops = all_planted_crops_in_season
	@calendar_days = (1..28).to_a
	@crops = reject_non_season_crops(@storage.all_crops)
	
	erb :calendar
end

get "/crop_directory" do
	@crops = @storage.all_crops

	erb :crop_directory
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
	values = [crop_id, season_id, param_hash[:plant_date],
						first_harvest, convert_sub_harvests_string(sub_harvest_array),
						param_hash[:amount]]

	add_planted_crop_to_db(values)
	redirect "/calendar/#{season.downcase}"
end

post "/:season/delete_single_crop" do
	season = convert_season_to_num(params[:season]) 
	id = params[:id]

	@storage.delete_single_planted_crop(id)

	redirect "/calendar/#{params[:season]}" 
end

post "/:season/delete_season_crops" do 
	season = convert_season_to_num(params[:season].downcase)

	@storage.delete_all_planted_crops_from_season(season)

	redirect "/calendar/#{params[:season]}"
end
