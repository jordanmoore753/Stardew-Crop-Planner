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

	def create_array_of_crop_values(tuple)
		tuple.values
	end
end

before do
  @storage = DatabasePersistence.new(logger)
end

after do
  @storage.disconnect
end

get "/" do
	@values = ["5", "1", "1", "11", "{14, 17, 20, 23}", "23"]
	@storage.add_planted_crop(@values)
	@yes = @storage.single_planted_crop(17)
	@crops = @storage.all_planted_crops 
	@egg = @storage.single_crop("Cauliflower")
	erb :index
end

get "/crops/:name" do 
	current_crop_name = convert_param_crop_name(params[:name])
	@current_crop = @storage.single_crop(current_crop_name)
	@prices = @storage.prices_single_crop(@current_crop[:id])[0]
	@img_name = convert_crop_name_img(current_crop_name)
	erb :single_crop
end

get "/calendar" do
	@calendar_days = (1..28).to_a
	erb :calendar
end
