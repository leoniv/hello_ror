require 'faker'
FactoryBot.define do
  factory :genre do
    name { Faker::Lorem.unique.word }
  end
end
