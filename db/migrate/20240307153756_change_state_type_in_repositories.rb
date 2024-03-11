class ChangeStateTypeInRepositories < ActiveRecord::Migration[7.1]
  def change
    change_column :repositories, :state, :boolean
  end
end
