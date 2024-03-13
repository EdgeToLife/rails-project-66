class ChangeStateTypeInRepositories < ActiveRecord::Migration[7.1]
  def up
    # Для PostgreSQL
    if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
      change_column :repositories, :state, 'integer USING CAST(state AS integer)'
    else
      # Для всех остальных баз данных, включая SQLite
      change_column :repositories, :state, :integer
    end
  end

  def down
    change_column :repositories, :state, :string
  end
end
