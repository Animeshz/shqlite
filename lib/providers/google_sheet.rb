require 'google_drive'

module Providers
  class GoogleSheet
    def initialize(credentials_path, spreadsheet_name)
      @session = GoogleDrive::Session.from_service_account_key(credentials_path)
      @spreadsheet = find_or_create_spreadsheet(spreadsheet_name)
    end

    def id
      @spreadsheet.id
    end

    def give_access(email, role = 'writer')
      @spreadsheet.acl.push(
        type: 'user',
        email_address: email,
        role: role
      )
    end

    def write_data_worksheet(headers, rows, worksheet_name = nil, clear = true)
      worksheet = find_or_create_worksheet(worksheet_name)

      if clear
        clear_worksheet(worksheet)
      end

      headers.each_with_index do |header, index|
        @worksheet[1, index + 1] = header
      end

      rows = sanitize_sheet_data(rows)
      rows.each_with_index do |row, row_index|
        row.each_with_index do |value, col_index|
          @worksheet[row_index + 2, col_index + 1] = value.to_s
        end
      end

      worksheet.save
    end

    def fetch_data_worksheet(worksheet_name = nil)
      worksheet = find_or_create_worksheet(worksheet_name)
      headers, *rows = worksheet.rows
      [headers, rows]
    end

    private

    def clear_worksheet(worksheet)
      @spreadsheet.batch_update([{
        update_cells: {
          range: {
            sheet_id: worksheet.gid,
            start_row_index: 0,
            end_row_index: worksheet.max_rows,
            start_column_index: 0,
            end_column_index: worksheet.max_cols
          },
          fields: 'userEnteredValue',  # Clears only the cell value
        }
      }])
    end

    def find_or_create_spreadsheet(spreadsheet_name)
      @session.spreadsheet_by_title(spreadsheet_name) || @session.create_spreadsheet(spreadsheet_name)
    end

    def find_or_create_worksheet(worksheet_name = nil)
      worksheet_name ||= 'Sheet1' # or whatever default you want

      @worksheet = @spreadsheet.worksheet_by_title(worksheet_name) ||
                   @spreadsheet.add_worksheet(worksheet_name)
    end

    # if it looks like a leading zero number, prefix with `'`
    def encode_for_sheet(cell)
      return "'#{cell}" if cell.to_s.match?(/\A0\d+/)
      cell
    end

    def sanitize_sheet_data(rows)
      rows.map do |row|
        row.map { |cell| encode_for_sheet(cell) }
      end
    end
  end
end
