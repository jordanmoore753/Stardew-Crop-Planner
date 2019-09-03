ENV["RACK_ENV"] = "test"

require "pg"
require "minitest/autorun"
require "rack/test"

require_relative "../app"
require_relative "../database_persistence"

class AppTest < Minitest::Test
	include Rack::Test::Methods

	def app
		Sinatra::Application
	end

	def session
		last_request.env["rack.session"]
	end

	def test_single_crop
		get "/crops/blue_jazz"

		assert_includes last_response.body, "Blue Jazz"
		assert_includes last_response.body, "Spring"
	end

end