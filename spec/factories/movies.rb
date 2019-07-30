FactoryBot.define do
  factory :movie do
    title_local { Faker::Book.unique.title }
    title_original { Faker::Movie.unique.quote }
    year_of_release { Random.rand 1905..2013 }
    rating { Random.rand 0..10 }
    description { Faker::Lorem.unique.paragraph }
    countries_of_production do
      Country.find_by! name: %w[USA Russia Italy].sample(Random.rand(0..3))
    end
    genres do
      Genre.map! Faker::Lorem.unique.words(10).sample(Random.rand(0..10))
    end
  end
end

