# frozen_string_literal: true

require 'test_helper'

class ChecksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    repository = repositories(:one)
    @check = repository.checks.last
  end

  test 'should show check' do
    sign_in @user
    get repository_check_url(repository_id: @check.repository_id, id: @check.id)
    assert_response :success
  end
end
