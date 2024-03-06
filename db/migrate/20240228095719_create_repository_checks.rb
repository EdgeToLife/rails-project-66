class CreateRepositoryChecks < ActiveRecord::Migration[7.1]
  def change
    create_table :repository_checks do |t|

      t.timestamps
    end
  end
end
