require_relative '../providers/sqlite'
require_relative '../providers/google_sheet'

module Services
  class GSheetToSQLiteService
    def initialize(db_path, credentials_path, spreadsheet_name, worksheet_name, table_name)
      @db_path = db_path
      @credentials_path = credentials_path
      @spreadsheet_name = spreadsheet_name
      @worksheet_name = worksheet_name
      @table_name = table_name
      @temp_table_name = "#{@table_name}_import_tmp"
    end

    def perform
      sqlite = Providers::SQLite.new(@db_path)
      google_sheet = Providers::GoogleSheet.new(@credentials_path, @spreadsheet_name)

      sqlite.drop_table(@temp_table_name)
      sqlite.clone_table_schema(@table_name, @temp_table_name)

      headers, rows = google_sheet.fetch_data_worksheet(@worksheet_name)
      sqlite.bulk_insert(@temp_table_name, headers, rows)

      puts "✅ Imported #{rows.size} rows to #{@temp_table_name}!"
    end
  end
end
