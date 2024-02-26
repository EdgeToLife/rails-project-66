require "test_helper"

class RepositoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @repository = repositories(:one)
    @creator = @repository.user
    fixture_path = 'files/response.json'
    @fixture_data = load_fixture(fixture_path)
    @parsed_data = JSON.parse(@fixture_data)
  end

  test 'should get repository index' do
    get repositories_url
    assert_response :success
  end

  test 'should get new repository page' do
    sign_in @user
    repository_params = { repository: { link: 'https://github.com/EdgeToLife/rails-project-65' } }
    stub_request(:get, "https://api.github.com/user/repos?per_page=100")
      .to_return(status: 200, body: @fixture_data, headers: { 'Content-Type': 'application/json' })

    post repositories_url, params: repository_params
    get new_repository_url
    assert_response :success
  end

  test 'should create repository' do
    sign_in @user

    attrs = {
      full_name: @parsed_data[0]['full_name']
    }

    assert_difference('Repository.count') do
      post repositories_url, params: { repository: attrs }
    end
    repository = Repository.find_by(attrs)
    assert { repository }
    assert_redirected_to repositories_path(repository)
    assert_response :redirect
  end
end
