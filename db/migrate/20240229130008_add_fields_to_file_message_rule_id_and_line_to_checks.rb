class AddFieldsToFileMessageRuleIdAndLineToChecks < ActiveRecord::Migration[7.1]
  def change
    add_column :repository_checks, :file, :string
    add_column :repository_checks, :message, :string
    add_column :repository_checks, :rule_id, :string
    add_column :repository_checks, :line, :string
  end
end
