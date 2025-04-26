require 'thor'
require_relative './services/gsheet_access_service'
require_relative './services/gsheet_to_sqlite_service'
require_relative './services/sqlite_to_gsheet_service'

class Shqlite < Thor
  desc "access", "Get url to the spreadsheet with given name, optionally add email to the access list."
  method_option :credentials_path, aliases: "-c", required: true, desc: "Path to Google Service Account credentials JSON"
  method_option :spreadsheet_name, aliases: "-s", required: true, desc: "Name of Spreadsheet"
  method_option :email, aliases: "-e", required: false, desc: "Email of the account to be given access"
  def access
    Services::GSheetAccessService.new(
      options[:credentials_path],
      options[:spreadsheet_name],
      options[:email]
    ).perform
  end

  desc "export", "Export an SQLite table to a Google Sheet"
  method_option :db_path, aliases: "-d", required: true, desc: "Path to SQLite database"
  method_option :credentials_path, aliases: "-c", required: true, desc: "Path to Google Service Account credentials JSON"
  method_option :spreadsheet_name, aliases: "-s", required: true, desc: "Name of Spreadsheet"
  method_option :worksheet_name, aliases: "-w", required: false, desc: "Name of Worksheet"
  method_option :table_name, aliases: "-t", required: true, desc: "Table name in SQLite DB"
  def export
    worksheet_name = options[:worksheet_name] || options[:table_name]

    Services::SQLiteToGSheetService.new(
      options[:db_path],
      options[:credentials_path],
      options[:spreadsheet_name],
      worksheet_name,
      options[:table_name]
    ).perform
  end

  desc "import", "Import a Google Sheet into SQLite DB with review and replace mechanism"
  method_option :db_path, aliases: "-d", required: true, desc: "Path to SQLite database"
  method_option :credentials_path, aliases: "-c", required: true, desc: "Path to Google Service Account credentials JSON"
  method_option :spreadsheet_name, aliases: "-s", required: true, desc: "Name of Spreadsheet"
  method_option :worksheet_name, aliases: "-w", required: false, desc: "Name of Worksheet"
  method_option :table_name, aliases: "-t", required: true, desc: "Table name in SQLite DB"
  def import
    worksheet_name = options[:worksheet_name] || options[:table_name]

    Services::GSheetToSQLiteService.new(
      options[:db_path],
      options[:credentials_path],
      options[:spreadsheet_name],
      worksheet_name,
      options[:table_name]
    ).perform
  end
end
