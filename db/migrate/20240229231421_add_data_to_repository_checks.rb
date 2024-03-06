class AddDataToRepositoryChecks < ActiveRecord::Migration[7.1]
  def change
    add_column :repository_checks, :data, :json
  end
end
