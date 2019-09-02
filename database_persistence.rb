require "pg"

class DatabasePersistence
  def initialize(logger)
    @db = if Sinatra::Base.production?
            PG.connect(ENV['DATABASE_URL'])
          else
            PG.connect(dbname: "stardew")
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

# planted_crop methods

  def all_planted_crops
    sql = "SELECT * FROM planted_crops;"
    crops = query(sql)

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
                                      amount_planted)
          VALUES ($1, $2, $3, $4, $5, $6);"

    query(sql, values[0], values[1], values[2],
          values[3], values[4], values[5])

    # @values = ["5", "1", "1", "11", "{NULL}", "23"] crop without regrow
    # ["5", "1", "1", "11", "{14, 17, 20, 23}", "23"] crop with regrow
  end

  def delete_all_planted_crops
    sql = "DELETE FROM planted_crops;"
    query(sql)
  end

  def delete_single_planted_crop(id)
    sql = "DELETE FROM planted_crops WHERE id = $1;"
    query(sql, id)
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
     amount_planted: tuple["amount_planted"].to_i
    }
  end
end