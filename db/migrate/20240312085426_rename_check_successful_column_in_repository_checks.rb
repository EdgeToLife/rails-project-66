class RenameCheckSuccessfulColumnInRepositoryChecks < ActiveRecord::Migration[7.1]
  def change
    rename_column :repository_checks, :check_successful, :passed
  end
end
