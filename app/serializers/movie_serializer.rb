class MovieSerializer < ActiveModel::Serializer
  attributes(*Movie.attribute_names)

  attribute :countries_of_production do
    movie.countries_of_production.pluck :name
  end

  attribute :genres do
    movie.genres.pluck :name
  end

  attribute :cover_image do
    url_helper.rails_blob_path(movie.cover_image, only_path: true) if\
      movie.cover_image.attached?
  end

  def url_helper
    Rails.application.routes.url_helpers
  end

  def movie
    object
  end
end
