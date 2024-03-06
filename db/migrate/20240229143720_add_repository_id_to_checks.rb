class AddRepositoryIdToChecks < ActiveRecord::Migration[7.1]
  def change
    add_reference :repository_checks, :repository, null: false, foreign_key: true
  end
end
