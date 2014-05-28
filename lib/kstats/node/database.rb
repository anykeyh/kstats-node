require 'sqlite3'

module Kstats
  module Node
    module Database
      class << self
        attr_reader :db

        def init
          @db = SQLite3::Database.new( Kstats::Node::CONFIG['db_dir'] )
          @db.execute [
            "CREATE TABLE IF NOT EXISTS probe_data (id INTEGER PRIMARY KEY ASC, date DATETIME, period_type STRING, probe_id STRING, probe_key STRING, probe_value NUMBER)",
            "CREATE INDEX IF NOT EXISTS probe_data_period_type ON probe_data(period_type)",
            "CREATE INDEX IF NOT EXISTS probe_data_date ON probe_data(date)",
            "CREATE INDEX IF NOT EXISTS probe_data_probe_id ON probe_data(probe_id)",
            "CREATE INDEX IF NOT EXISTS probe_data_probe_key ON probe_data(probe_key)"
            ].join(";")
        end

        def execute query
          @db.execute(query)
        end

        def save_probes_data probes, type
          time = Time.now

          probes.each do |name, values|
            @db.close
            @db = SQLite3::Database.new( Kstats::Node::CONFIG['db_dir'] )

            sql = <<SQL
INSERT INTO probe_data (date, period_type, probe_id, probe_key, probe_value)
VALUES (?, ?, ?, ?, ?)
SQL
            values.each do |probe_key, probe_value|
              @db.execute(sql, time.to_s, type.to_s, name.to_s, probe_key.to_s, probe_value)
            end
          end
        end
      end #<< self
    end #Class
  end #Node
end #Kstats