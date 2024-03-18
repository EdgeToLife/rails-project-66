# frozen_string_literal: true

require 'test_helper'

class RepositoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @repository = repositories(:repo_one)
    @check = @repository.checks.last
    fixture_path = 'files/response.json'
    @fixture_data = load_fixture(fixture_path)
    @parsed_data = JSON.parse(@fixture_data)
  end

  test 'should get repository index' do
    sign_in @user
    get repositories_url
    assert_response :success
  end

  test 'should get new repository page' do
    sign_in @user
    repository_params = { repository: { link: 'https://github.com/EdgeToLife/rails-project-65' } }
    stub_request(:get, 'https://api.github.com/user/repos?per_page=100')
      .to_return(status: 200, body: @fixture_data, headers: { 'Content-Type': 'application/json' })
    get new_repository_url
    assert_response :success
  end

  test 'should create repository' do
    sign_in @user
    attrs = {
      github_id: @parsed_data[0]['id']
    }
    assert_difference('Repository.count') do
      post repositories_url, params: { repository: attrs }
    end
    repository = Repository.find_by(attrs)
    assert { repository }
    assert_redirected_to repositories_path
  end

  test 'should show repository' do
    sign_in @user
    get repository_url(@repository)
    assert_response :success
  end

  # test 'should analyze repository' do
  #   sign_in @user
  #   ApplicationContainer.resolve(:repository_analyzer_job).perform_later(@check)
  #   expected_value = true
  #   actual_value = @check.passed

  #   assert_equal expected_value, actual_value
  # end
end
