# frozen_string_literal: true

class JavascriptFormatter
  def self.format_data(data, base_path)
    formatted_data = data.filter_map do |item|
      base_pathname = Pathname.new(base_path)
      file_pathname = Pathname.new(item['filePath'])
      relative_path = file_pathname.relative_path_from(base_pathname).to_s
      messages = item['messages'].map do |message|
        {
          'ruleId' => message['ruleId'],
          'line' => message['line'],
          'column' => message['column'],
          'message' => message['message']
        }
      end
      error_count = messages.size
      {
        'filePath' => relative_path,
        'messages' => messages,
        'errorCount' => error_count
      }
    end.compact
    total_error_count = formatted_data.sum { |item| item['errorCount'] }
    [formatted_data, total_error_count]
  end
end
