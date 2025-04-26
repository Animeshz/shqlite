require_relative '../providers/google_sheet'

module Services
  class GSheetAccessService
    def initialize(credentials_path, spreadsheet_name, email)
      @credentials_path = credentials_path
      @spreadsheet_name = spreadsheet_name
      @email = email
    end

    def perform
      sheet_provider = Providers::GoogleSheet.new(@credentials_path, @spreadsheet_name)
      if @gmail != nil then
        sheet_provider.give_access(@email)
        puts "✅ Access added!"
      end

      puts "↗️ Access your sheet here: https://docs.google.com/spreadsheets/d/#{sheet_provider.id}/edit"
    end
  end
end
