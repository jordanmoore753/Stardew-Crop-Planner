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

	def test_crop_by_season
		get "/calendar/fall"

		assert_includes last_response.body, "<option>Amaranth</option>"
		assert_includes last_response.body, "<option>Yam</option>"

		get "/calendar/spring"

		assert_includes last_response.body, "<option>Blue Jazz</option>"
		assert_includes last_response.body, "<option>Tulip</option>"

		get "/calendar/summer"

		assert_includes last_response.body, "<option>Blueberry</option>"
		assert_includes last_response.body, "<option>Wheat</option>"
	end
end