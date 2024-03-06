class RemoveColumnsFromRepositoryChecks < ActiveRecord::Migration[7.1]
  def change
    remove_column :repository_checks, :file, :string
    remove_column :repository_checks, :message, :string
    remove_column :repository_checks, :rule_id, :string
    remove_column :repository_checks, :line, :string
  end
end
