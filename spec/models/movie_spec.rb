require 'rails_helper'

RSpec.describe Movie, type: :model do
  it { should have_db_index :title_local }
  it { should validate_presence_of :title_local }
  it { should validate_inclusion_of(:year_of_release)
    .in_range(1895 .. Date.today.year + 5)}
  it { should validate_inclusion_of(:rating).in_range(0 .. 10) }
  it { should have_and_belong_to_many :genres }
  it { should have_many(:countries_of_production)
        .through(:countries_of_production)
        .class_name(:Country) }
  it { should have_one_attached :cover_image }
end
