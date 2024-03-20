# frozen_string_literal: true

require 'test_helper'

class ChecksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test 'should show check' do
    check = repository_checks(:one)
    sign_in @user
    get repository_check_url(repository_id: check.repository_id, id: check.id)
    assert_response :success
  end

  test 'should create check repository' do
    repo_without_checks = repositories(:repo_two)
    attrs = {
      aasm_state: 'finished',
      passed: true,
      error_count: 0,
      commit_id: 'fcad3c9'
    }
    sign_in @user
    assert_difference('Repository::Check.count') do
      post repository_checks_path(repo_without_checks)
    end
    assert_redirected_to repository_path(repo_without_checks)
    check = Repository::Check.find_by(attrs)
    assert { check }
  end
end
