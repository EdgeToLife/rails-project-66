class AddGithubIdToRepositories < ActiveRecord::Migration[7.1]
  def change
    add_column :repositories, :github_id, :integer
  end
end
