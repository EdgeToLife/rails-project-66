class AddStateToRepository < ActiveRecord::Migration[7.1]
  def change
    add_column :repositories, :state, :string
  end
end
