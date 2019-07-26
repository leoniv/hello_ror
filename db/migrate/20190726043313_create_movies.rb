class CreateMovies < ActiveRecord::Migration[5.2]
  def change
    create_table :movies do |t|
      t.string :title_original
      t.string :title_local
      t.integer :year_of_release
      t.integer :rating
      t.text :description

      t.timestamps
    end
    add_index :movies, :title_local
  end
end
