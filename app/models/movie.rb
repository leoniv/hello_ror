class Movie < ApplicationRecord
  include ::Filterable
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
    filter_scope attribute, ->(value) { where("#{attribute} like ?", value) }
  end

  %I[year_of_release rating].each do |attribute|
    filter_scope "#{attribute}_from",
                 ->(from) { where("#{attribute} >= ?", from) }
    filter_scope "#{attribute}_to", ->(to) { where("#{attribute} <= ?", to) }
  end

  filter_scope :countries_of_production, ->(name) do
    joins(:countries_of_production)
      .where('countries.name like ?', name)
      .distinct
  end

  filter_scope :genres, ->(name) do
    joins(:genres)
      .where(genres: { name: name } )
      .distinct
  end

  sort_by %w[rating year_of_release]
end

