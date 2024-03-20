# frozen_string_literal: true

class OctokitClientStub
  attr_reader :options

  def initialize(*); end

  def commits(_repo_full_name)
    MyCommit.new('fcad3c9fc799961f89be4131cea224a2ad3f2ade')
  end

  def create_hook(_repo_full_name, _, _webhook_options); end

  def hooks(_repo_full_name)
    []
  end

  def repos
    json = Rails.root.join('test/fixtures/files/response.json').read
    JSON.parse(json)
  end

  def repository(_github_id)
    json = Rails.root.join('test/fixtures/files/repo_info.json').read
    JSON.parse(json)
  end
end

MyCommit = Struct.new(:sha) do
  def first
    self
  end
end
