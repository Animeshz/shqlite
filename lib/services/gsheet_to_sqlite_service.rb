require 'csv'
require 'tempfile'

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

      if show_diff_and_confirm_changes!(sqlite)
        sqlite.drop_table(@table_name)
        sqlite.rename_table(@temp_table_name, @table_name)
        puts "✅ Changes accepted!"
        puts "✅ Imported #{rows.size} rows to #{@table_name}!"
      else
        puts "❌ Changes discarded."

        print "Drop temporary import table #{@temp_table_name}? (y/n): "
        answer = $stdin.gets.chomp
        if answer.downcase.start_with?('y')
          sqlite.drop_table(@temp_table_name)
          puts "✅ #{@temp_table_name} dropped!"
        end
      end
    end

    private

    def show_diff_and_confirm_changes!(sqlite)
      c1, r1 = sqlite.fetch_table_data(@table_name)
      c2, r2 = sqlite.fetch_table_data(@temp_table_name)

      org_file = Tempfile.new('org.csv')
      tmp_file = Tempfile.new('tmp.csv')

      begin
        CSV.open(org_file.path, "w") { |csv| r1.each { |row| csv << row } }
        CSV.open(tmp_file.path, "w") { |csv| r2.each { |row| csv << row } }

        system("diff -u #{org_file.path} #{tmp_file.path} | #{ENV['SHQLITE_PAGER'] || 'less'}")

        print "Accept changes? (y/n): "
        answer = $stdin.gets.chomp
        answer.downcase.start_with?('y')
      ensure
        org_file.close!
        tmp_file.close!
      end
    end
  end
end
