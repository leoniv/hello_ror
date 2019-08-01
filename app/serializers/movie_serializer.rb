class MovieSerializer < ActiveModel::Serializer
  attributes(*Movie.attribute_names)

  attribute :countries_of_production do
    movie.countries_of_production.pluck :name
  end

  attribute :genres do
    movie.genres.pluck :name
  end

  attribute :cover_image do
    rails_blob_path(movie.cover_image, path_only: true) if\
      movie.cover_image.attached?
  end

  def movie
    object
  end
end
