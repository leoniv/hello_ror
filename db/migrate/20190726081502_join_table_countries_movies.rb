class JoinTableCountriesMovies < ActiveRecord::Migration[5.2]
  def change
    create_join_table :countries, :movies do |t|
      t.index [:movie_id, :country_id], unique: true
    end
  end
end
