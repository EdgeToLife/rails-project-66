# frozen_string_literal: true

require 'test_helper'

class ChecksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @repository = repositories(:repo_one)
    @check = repository_checks(:one)
  end

  test 'should show check' do
    sign_in @user
    get repository_check_url(repository_id: @check.repository_id, id: @check.id)
    assert_response :success
  end

  test 'should create check repository' do
    sign_in @user
    post repository_checks_path(@repository)
    assert_redirected_to repository_path(@repository)
  end
end
