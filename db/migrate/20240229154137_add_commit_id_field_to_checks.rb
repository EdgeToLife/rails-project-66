class AddCommitIdFieldToChecks < ActiveRecord::Migration[7.1]
  def change
    add_column :repository_checks, :commit_id, :string
  end
end
