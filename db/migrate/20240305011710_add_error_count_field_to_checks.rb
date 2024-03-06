class AddErrorCountFieldToChecks < ActiveRecord::Migration[7.1]
  def change
    add_column :repository_checks, :error_count, :integer
  end
end
