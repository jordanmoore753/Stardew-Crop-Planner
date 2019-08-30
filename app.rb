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
	@crops = @storage.all_crops 
	erb :index
end
