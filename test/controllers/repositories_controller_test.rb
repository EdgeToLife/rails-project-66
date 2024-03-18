# frozen_string_literal: true

require 'test_helper'

class RepositoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @repository = repositories(:repo_one)
    @check = @repository.checks.last
    fixture_path = 'files/repo_info.json'
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
    get new_repository_url
    assert_response :success
  end

  test 'should create repository' do
    sign_in @user
    attrs = {
      github_id: @parsed_data['id'],
      full_name: @parsed_data['full_name'],
      language: @parsed_data['language'].downcase,
      git_url: @parsed_data['git_url'],
      ssh_url: @parsed_data['ssh_url']
    }
    assert_difference('Repository.count') do
      post repositories_url, params: { repository: { github_id: attrs[:github_id] } }
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
end
