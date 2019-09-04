# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'pg'
require 'minitest/autorun'
require 'rack/test'

require_relative '../app'
require_relative '../database_persistence'

# This is the testing class.
class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def session
    last_request.env['rack.session']
  end

  def test_single_crop
    get '/crops/selection?crop_name=Blue+Jazz'

    assert_includes last_response.body, 'Blue Jazz'
    assert_includes last_response.body, 'Spring'
  end

  def test_crop_fall
    get '/calendar/fall'

    assert_includes last_response.body, '<option>Amaranth</option>'
    assert_includes last_response.body, '<option>Yam</option>'
  end

  def test_crop_spring
    get '/calendar/spring'

    assert_includes last_response.body, '<option>Blue Jazz</option>'
    assert_includes last_response.body, '<option>Tulip</option>'
  end

  def test_crop_summer
    get '/calendar/summer'

    assert_includes last_response.body, '<option>Blueberry</option>'
    assert_includes last_response.body, '<option>Wheat</option>'
  end

  def test_add_crop
    post '/fall/delete_season_crops'

    post '/add_crop_calendar', 'crop_name' => 'Amaranth',
                               'plant_date' => '3',
                               'amount_planted' => 40

    get last_response['Location']

    assert_includes last_response.body, 'Amara...'
    assert_includes last_response.body, 'x40'
    assert_includes last_response.body, '$6000'

    post '/fall/delete_season_crops'
  end

  def test_delete_single_crop
    # unable to grab the parameter from the route
  end

  def test_delete_all_crops
    post '/fall/delete_season_crops'

    post '/add_crop_calendar', 'crop_name' => 'Amaranth',
                               'plant_date' => '3',
                               'amount_planted' => 40

    get last_response['Location']

    assert_includes last_response.body, 'Amara...'

    post '/fall/delete_season_crops'

    get '/calendar/fall'

    refute_includes last_response.body, 'Amara...'
  end

  def test_profit
    post '/fall/delete_season_crops'

    post '/add_crop_calendar', 'crop_name' => 'Amaranth',
                               'plant_date' => '3',
                               'amount_planted' => 40

    get last_response['Location']

    assert_includes last_response.body, '$3,200'

    post '/fall/delete_season_crops'
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
end
