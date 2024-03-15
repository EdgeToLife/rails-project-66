# frozen_string_literal: true

class RubyFormatter
  def self.format_data(data, base_path)
    formatted_data = data['files'].filter_map do |file|
      offenses = file['offenses']
      next unless offenses.any?

      file_path = file['path']
      relative_path = file_path.sub(base_path.to_s, '')

      messages = offenses.map do |offense|
        {
          'ruleId' => offense['cop_name'],
          'line' => offense['location']['line'],
          'column' => offense['location']['column'],
          'message' => offense['message']
        }
      end

      {
        'filePath' => relative_path,
        'messages' => messages
      }
    end.compact
    total_error_count = data['summary']['offense_count']
    [formatted_data, total_error_count]
  end
end
