class CreateGenres < ActiveRecord::Migration[5.2]
  def change
    create_table :genres, id: false do |t|
      t.string :name, primary_key: true
      t.timestamps
    end
  end
end
