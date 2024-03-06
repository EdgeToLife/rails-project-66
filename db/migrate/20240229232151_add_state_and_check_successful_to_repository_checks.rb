class AddStateAndCheckSuccessfulToRepositoryChecks < ActiveRecord::Migration[7.1]
  def change
    add_column :repository_checks, :state, :string
    add_column :repository_checks, :check_successful, :boolean
  end
end
