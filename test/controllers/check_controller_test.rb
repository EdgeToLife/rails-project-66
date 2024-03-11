require 'test_helper'

class ChecksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @repository = repositories(:one)
    @creator = @repository.user
    @check = @repository.checks.last
    fixture_path = 'files/response.json'
    @fixture_data = load_fixture(fixture_path)
    @parsed_data = JSON.parse(@fixture_data)
  end

  test 'should show check' do
    sign_in @user
    get repository_check_url(repository_id: @check.repository_id, id: @check.id)
    assert_response :success
  end
end
