require "pg"

class DatabasePersistence
  def initialize(logger)
    @db = if Sinatra::Base.production?
            PG.connect(ENV['DATABASE_URL'])
          else
            PG.connect(dbname: "sdplanner")
          end
    @logger = logger
  end

  def disconnect
    @db.close
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end

# all crops methods

  def all_crops
    sql = "SELECT * FROM crops;"
    crops = query(sql)

    crops.map do |tuple|
      tuple_to_crop_hash(tuple)
    end
  end

  def single_crop(name)
    crops = all_crops
    crops.map { |tuple| return tuple if tuple[:name] == name }
  end

  def single_crop_by_id(id)
    crops = all_crops
    crops.map { |tuple| return tuple if tuple[:id].to_i == id }
  end

  def prices_single_crop(id)
    sql = "SELECT sell_price, seed_price FROM crop_prices
           WHERE crop_id = $1;"
    cost = query(sql, id)

    cost.map { |tuple| tuple_to_crop_hash_prices(tuple) }
  end

# planted_crop methods

  def all_planted_crops(user_id)
    sql = "SELECT * FROM planted_crops WHERE user_id = $1;"
    crops = query(sql, user_id)

    crops.map do |tuple|
      tuple_to_crop_hash_planted(tuple)
    end
  end

  def single_planted_crop(id)
    sql = "SELECT * FROM planted_crops WHERE id = $1;"
    crop = query(sql, id)

    crop.map { |tuple| tuple_to_crop_hash_planted(tuple) }
  end

  def add_planted_crop(values)
    sql = "INSERT INTO planted_crops (crop_id, season_id, planted_on,
                                      first_harvest, sub_harvests,
                                      amount_planted, user_id)
          VALUES ($1, $2, $3, $4, $5, $6, $7);"

    query(sql, values[0], values[1], values[2],
          values[3], values[4][0..-1], values[5], values[6])

    # @values = ["5", "1", "1", "11", "{NULL}", "23"] crop without regrow
    # ["5", "1", "1", "11", "{14, 17, 20, 23}", "23"] crop with regrow
  end

  def delete_all_planted_crops(user_id)
    sql = "DELETE FROM planted_crops WHERE user_id = $1;"
    query(sql, user_id)
  end

  def delete_single_planted_crop(id, user_id)
    sql = "DELETE FROM planted_crops WHERE id = $1 AND user_id = $2;"
    query(sql, id, user_id)
  end

  def delete_all_planted_crops_from_season(season, user_id)
    sql = "DELETE FROM planted_crops WHERE season_id = $1 AND user_id = $2;"
    query(sql, season, user_id)
  end

  # user methods

  def load_user_by_name(username)
    sql = "SELECT * FROM users WHERE name = $1;"
    user = query(sql, username)

    user.map { |tuple| tuple_to_user_hash(tuple) }
  end

  def add_user_to_database(username, pw)
    sql = "INSERT INTO users (name, password) 
           VALUES ($1, $2);"
    query(sql, username, pw)
  end

  def load_user_id_by_name(name)
    array = load_user_by_name(name)
    array[0][:id]
  end

  private

  def tuple_to_crop_hash(tuple)
    {id: tuple["id"], 
     name: tuple["name"], 
     season: tuple["season"].to_i,
     until_harvest: tuple["until_harvest"].to_i,
     regrow: tuple["regrow"].to_i,
     produces: tuple["produces"].to_i
    }
  end

  def tuple_to_crop_hash_planted(tuple)
    replacements = ["{", "}"]
    replacements.each { |char| tuple["sub_harvests"].gsub!(char, "") }
    tuple["sub_harvests"] = tuple["sub_harvests"].split(',').map(&:to_i)

    {id: tuple["id"], 
     crop_id: tuple["crop_id"].to_i, 
     season_id: tuple["season_id"].to_i,
     first_harvest: tuple["first_harvest"].to_i,
     sub_harvests: tuple["sub_harvests"].to_a,
     amount_planted: tuple["amount_planted"].to_i,
     planted_on: tuple["planted_on"].to_i
    }
  end

  def tuple_to_crop_hash_prices(tuple)
    {id: tuple["id"], 
     crop_id: tuple["crop_id"].to_i, 
     sell_price: tuple["sell_price"].to_i,
     seed_price: tuple["seed_price"].to_i
    }
  end

  def tuple_to_user_hash(tuple)
    {id: tuple["id"].to_i, 
     name: tuple["name"].to_s, 
     password: tuple["password"].to_s
    }
  end
end