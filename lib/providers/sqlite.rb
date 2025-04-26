require 'sqlite3'

module Providers
  class SQLite
    def initialize(db_path)
      @db = SQLite3::Database.new(db_path)
    end

    def fetch_table_data(table_name)
      stmt = @db.prepare("SELECT * FROM #{table_name}")
      result = stmt.execute
      [result.columns, result.to_a]
    end
  end
end
