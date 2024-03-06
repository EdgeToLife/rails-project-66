class ChangeDefaultForCheckSuccessfulInRepositoryChecks < ActiveRecord::Migration[7.1]
  def change
    change_column_default :repository_checks, :check_successful, false
  end
end
