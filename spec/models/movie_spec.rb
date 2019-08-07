# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Movie, type: :model do
  describe 'validators' do
    it { should validate_presence_of :title_local }
    it { should validate_inclusion_of(:year_of_release)
      .in_range(1895 .. Date.today.year + 5)}
    it { should validate_inclusion_of(:rating).in_range(0 .. 10) }
  end

  describe 'schema' do
    it { should have_db_index :title_local }
    it { should have_and_belong_to_many :genres }
    it { should have_and_belong_to_many(:countries_of_production)
          .class_name(:Country) }
  end

  describe '#cover_image' do
    let(:instance) { create(:movie) }

    it { expect(instance.cover_image).to be_attached }
  end

  describe 'scopes' do
    let(:movies) do
      5.times.to_a.map do |i|
        create :movie,
               title_local: "title local #{i}",
               title_original: "title original #{i}",
               year_of_release: 1990 + i,
               rating: i,
               countries_of_production: (3.times.to_a.map do |j|
                 create(:country, name: "Fake country #{i} #{j}")
               end),
               genres: (3.times.to_a.map do |j|
                 create(:genre, name: "genre #{i} #{j}")
               end)
      end
    end

    before :example do
      movies
    end

    subject { Movie }

    its(:title_local, '%local 2%') { should match_array movies[2] }
    its(:title_original, '%original 3%') { should match_array movies[3] }
    its(:year_of_release_from, 1992) { should match_array movies[2..4] }
    its(:year_of_release_to, 1992) { should match_array movies[0..2] }
    its(:rating_from, 3) { should match_array movies[3..4] }
    its(:rating_to, 3) { should match_array movies[0..3] }
    its(:countries_of_production, '%country _ 2') { should match_array movies }
    its(:countries_of_production, '%country 2%') do
      should match_array movies[2]
    end
    its(:genres, 'genre 4 1') { should match_array movies[4] }
    its(:genres, ['genre 1 1', 'genre 2 0']) do
      should match_array movies[1..2]
    end
  end
end

