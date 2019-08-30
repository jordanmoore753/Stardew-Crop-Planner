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

  def all_crops
    sql = "SELECT * FROM crops;"
    crops = query(sql)

    crops.map do |tuple|
      tuple_to_crop_hash(tuple)
    end
  end

  def tuple_to_crop_hash(tuple)
    {id: tuple["id"], 
     name: tuple["name"], 
     season: tuple["season"].to_i,
     until_harvest: tuple["until_harvest"].to_i,
     regrow: tuple["regrow"].to_i,
     produces: tuple["produces"].to_i
    }
  end
end