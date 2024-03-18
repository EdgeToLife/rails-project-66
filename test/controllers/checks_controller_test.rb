# frozen_string_literal: true

require 'test_helper'

class ChecksControllerTest < ActionDispatch::IntegrationTest
  test 'should create check repository via API' do
    repository = repositories(:repo_one)
    json_payload = { repository: { id: repository.github_id } }
    assert_difference('Repository::Check.count') do
      post api_checks_path, params: json_payload, as: :json
    end
    assert_response :success
  end
end
