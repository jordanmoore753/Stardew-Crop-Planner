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
