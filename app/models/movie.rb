class Movie < ApplicationRecord
  LUMIERE_YEAR = 1895
  FUTURE_YEAR = Date.today.year + 5

  validates :title_local, presence: true
  validates :year_of_release, inclusion: (LUMIERE_YEAR .. FUTURE_YEAR), allow_blank: true
  validates :rating, inclusion: (0 .. 10), allow_blank: true
  has_and_belongs_to_many :genres
  has_and_belongs_to_many :countries_of_production, class_name: "Country"
  has_one_attached :cover_image
end
