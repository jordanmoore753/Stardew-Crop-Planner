# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'pg'
require 'minitest/autorun'
require 'rack/test'

require_relative '../app'
require_relative '../database_persistence'

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def user_reg_and_login
    post "/register", params = { username: "CarsonDaly", password: "123456789" }
    post "/login", params = { username: "CarsonDaly", password: "123456789" }
  end 

  def user_destroy
    post "/delete_user", params = { name: "CarsonDaly" }
  end

  def session
    last_request.env['rack.session']
  end

  def test_user_register
    get "/login"

    assert_includes last_response.body, "Login"
    assert_includes last_response.body, "Register"

    post "/register", params = { username: "CarsonDaly", password: "123456789" }

    get last_response["Location"]

    assert_includes last_response.body, "Login"
    assert_includes last_response.body, "Register"
    assert_includes last_response.body, "User created."

    user_destroy
  end

  def test_user_register_fail 
    post "/register", params = { username: "CarsonDaly", password: "123456789" }

    post "/register", params = { username: "CarsonDaly", password: "123456789" }

    get last_response['Location']

    assert_includes last_response.body, "Username is unavailable."

    user_destroy
  end

  def test_user_login
    user_reg_and_login
    get last_response["Location"]

    assert_includes last_response.body, "Spring"
    assert_equal "CarsonDaly", session[:curr_user]

    user_destroy
  end

  def test_user_login_fail
    post "/register", params = { username: "CarsonDaly", password: "123456789" }

    post "/login", params = { username: "CarsonDaly", password: "12345789" }

    get last_response['Location']

    assert_includes last_response.body, "Invalid credentials."

    user_destroy
  end

  def test_single_crop
    get '/crops/selection?crop_name=Blue+Jazz'

    assert_includes last_response.body, 'Blue Jazz'
    assert_includes last_response.body, 'Spring'
  end

  def test_calendar
    user_reg_and_login

    get last_response["Location"]

    assert_includes last_response.body, "Spring"
    assert_includes last_response.body, "Profit"

    user_destroy
  end

  def test_add_crop
    user_reg_and_login

    post '/add_crop_calendar', 'crop_name' => 'Amaranth',
                               'plant_date' => '3',
                               'amount_planted' => 40

    get last_response['Location']

    assert_includes last_response.body, 'Amara...'
    assert_includes last_response.body, 'x40'
    assert_includes last_response.body, '$6000'

    post '/fall/delete_season_crops'

    user_destroy
  end

  def test_profit
    user_reg_and_login

    post '/add_crop_calendar', 'crop_name' => 'Amaranth',
                               'plant_date' => '3',
                               'amount_planted' => 40

    get last_response['Location']

    assert_includes last_response.body, '$3,200'

    post '/fall/delete_season_crops'

    get last_response['Location']

    assert_includes last_response.body, '$0'

    user_destroy
  end

  def test_index
    get '/'

    assert_includes last_response.body, 'Stardew Valley Crop Assistant'
    assert_includes last_response.body, 'Crop Directory'
    assert_includes last_response.body, 'Crop Planner'
    assert_includes last_response.body, 'interactive calendar'
  end

  def test_crop_directory
    get '/crop_directory'

    assert_includes last_response.body, 'Crop Directory Search'
    assert_includes last_response.body, 'Choose the plant'
    assert_includes last_response.body, 'Return to Index'
  end

  def test_delete_crops
    user_reg_and_login

    post '/add_crop_calendar', 'crop_name' => 'Amaranth',
                               'plant_date' => '3',
                               'amount_planted' => 40

    get last_response['Location']

    post '/fall/delete_season_crops'

    get last_response['Location']

    refute_includes last_response.body, 'Amara...'
    refute_includes last_response.body, 'x40'
    refute_includes last_response.body, '$6000'

    user_destroy   
  end
end
