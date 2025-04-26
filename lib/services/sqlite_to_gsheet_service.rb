require_relative '../providers/sqlite'
require_relative '../providers/google_sheet'

module Services
  class SQLiteToGSheetService
    def initialize(db_path, credentials_path, spreadsheet_name, worksheet_name, table_name)
      @db_path = db_path
      @credentials_path = credentials_path
      @spreadsheet_name = spreadsheet_name
      @worksheet_name = worksheet_name
      @table_name = table_name
    end

    def perform
      sqlite = Providers::SQLite.new(@db_path)
      google_sheet = Providers::GoogleSheet.new(@credentials_path, @spreadsheet_name)

      columns, rows = sqlite.fetch_table_data(@table_name)

      google_sheet.write_data_worksheet(columns, rows, @worksheet_name, clear = true)
      puts "✅ Exported #{rows.size} rows to Google Sheet!"
    end
  end
end
