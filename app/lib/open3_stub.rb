# frozen_string_literal: true

class Open3Stub
  attr_reader :status

  def initialize(exit_status)
    @status = exit_status
  end

  def success?
    @status.zero?
  end

  def self.popen3(cmd)
    if cmd.include?('git')
      stdout = ''
    elsif cmd.include?('rubocop')
      stdout = Rails.root.join('test/fixtures/files/rubocop_result.json').read
    elsif cmd.include?('eslint')
      stdout = Rails.root.join('test/fixtures/files/eslint_result.json').read
    end

    exit_status = Open3Stub.new(0)

    [stdout, exit_status]
  end
end
