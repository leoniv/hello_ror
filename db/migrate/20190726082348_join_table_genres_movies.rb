class JoinTableGenresMovies < ActiveRecord::Migration[5.2]
  def change
    create_table :genres_movies, id: false do |t|
      t.string :genre_name, foregin_key: :genres, not_null: true
      t.integer :movie_id, foregin_key: :movies, not_null: true
      t.index [:movie_id, :genre_name], unique: true
    end
  end
end
