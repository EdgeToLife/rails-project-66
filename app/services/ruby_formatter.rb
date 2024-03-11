# frozen_string_literal: true

class RubyFormatter
  def self.format_data(data)
    formatted_data = data['files'].map do |file|
      offenses = file['offenses']
      next unless offenses.any?

      messages = offenses.map do |offense|
        {
          'ruleId' => offense['cop_name'],
          'line' => offense['location']['line'],
          'column' => offense['location']['column'],
          'message' => offense['message']
        }
      end

      {
        'filePath' => file['path'],
        'messages' => messages
      }
    end.compact
    total_error_count = data['summary']['offense_count']
    [formatted_data, total_error_count]
  end
end
