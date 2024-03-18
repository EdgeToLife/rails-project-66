# frozen_string_literal: true

class OctokitClientStub
  attr_reader :options

  def initialize(*); end

  def repos
    json = Rails.root.join('test/fixtures/files/response.json').read
    JSON.parse(json)
  end

  def repository(_github_id)
    json = Rails.root.join('test/fixtures/files/repo_info.json').read
    JSON.parse(json)
  end

  def hooks(_repo_gull_name)
    []
  end

  def create_hook(_repo_full_name, _, _webhook_options)
  end
end
