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

    def drop_table(table_name)
      @db.execute("DROP TABLE IF EXISTS #{table_name}")
    end

    def rename_table(from_table, to_table)
      @db.execute("ALTER TABLE #{from_table} RENAME TO #{to_table};")
    end

    def clone_table_schema(from_table, to_table)
      schema = @db.get_first_value("SELECT sql FROM sqlite_master WHERE type='table' AND name=?", [from_table])
      raise "Table #{from_table} does not exist!" unless schema

      cloned_schema = schema.sub(/CREATE TABLE #{Regexp.quote(from_table)}/i, "CREATE TABLE #{to_table}")
      @db.execute(cloned_schema)
    end

    def bulk_insert(table_name, headers, rows)
      return if rows.empty?

      columns = headers.map { |h| "\"#{h}\"" }.join(", ")
      placeholders = rows.map { "(#{(["?"] * headers.size).join(", ")})" }.join(", ")
      values = rows.flatten

      sql = "INSERT INTO #{table_name} (#{columns}) VALUES #{placeholders}"

      @db.execute(sql, values)
    end
  end
end
