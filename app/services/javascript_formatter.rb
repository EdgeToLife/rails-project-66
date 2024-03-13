# frozen_string_literal: true

class JavascriptFormatter
  def self.format_data(data)
    formatted_data = data.filter_map do |item|
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
        'filePath' => item['filePath'],
        'messages' => messages,
        'errorCount' => error_count
      }
    end.compact
    total_error_count = formatted_data.sum { |item| item['errorCount'] }
    [formatted_data, total_error_count]
  end
end
