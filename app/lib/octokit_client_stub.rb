# frozen_string_literal: true

class OctokitClientStub
  attr_reader :options

  def initialize(options = {})
    @options = options
  end

  def repos
    json = Rails.root.join('test/fixtures/files/response.json').read
    JSON.parse(json)
  end
end
