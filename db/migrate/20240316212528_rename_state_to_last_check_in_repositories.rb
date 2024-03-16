class RenameStateToLastCheckInRepositories < ActiveRecord::Migration[7.1]
  def change
    rename_column :repositories, :state, :last_check
  end
end
