class Movie < ApplicationRecord
  LUMIERE_YEAR = 1895
  FUTURE_YEAR = Date.today.year + 5

  validates :title_local, presence: true
  validates :year_of_release, inclusion: (LUMIERE_YEAR..FUTURE_YEAR),
                              allow_blank: true
  validates :rating, inclusion: (0..10), allow_blank: true
  has_and_belongs_to_many :genres, association_foreign_key: :genre_name
  has_and_belongs_to_many :countries_of_production, class_name: 'Country'
  has_one_attached :cover_image

  %I[title_original title_local].each do |attribute|
    scope attribute, ->(value) { where("#{attribute} like ?", value) }
  end

  %I[year_of_release rating].each do |attribute|
    scope attribute, ->(from, to) { where(attribute => from..to) }
  end

  scope :countries_of_production, ->(name) do
    joins(:countries_of_production)
      .where('countries.name like ?', name)
      .distinct
  end

  scope :genres, ->(name) do
    joins(:genres)
      .where(genres: { name: name } )
      .distinct
  end
end

