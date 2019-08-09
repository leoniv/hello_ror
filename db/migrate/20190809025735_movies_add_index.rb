class MoviesAddIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :movies, :title_original
    add_index :movies, :year_of_release
    add_index :movies, :rating
  end
end
