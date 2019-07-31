FactoryBot.define do
  factory :movie do
    title_local { Faker::Book.unique.title }
    title_original { Faker::Movie.unique.quote }
    year_of_release { Random.rand 1905..2013 }
    rating { Random.rand 0..10 }
    description { Faker::Lorem.unique.paragraph }

    transient do
      genres_count { Random.rand 0..5 }
      countries_count { Random.rand 0..5 }
    end

    factory :countries_of_production, parent: :country

    after :create do |movie, e|
      movie.cover_image.attach(io: StringIO.new('cover'), filename: 'cover.txt')
      create_list(:genre, e.genres_count, movies: [movie])
      create_list(:countries_of_production, e.countries_count)
    end
  end
end

