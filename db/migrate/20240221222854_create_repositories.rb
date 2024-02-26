class CreateRepositories < ActiveRecord::Migration[7.1]
  def change
    create_table :repositories do |t|
      t.string :name
      t.string :full_name
      t.string :language
      t.string :git_url
      t.string :ssh_url

      t.timestamps
    end
  end
end
