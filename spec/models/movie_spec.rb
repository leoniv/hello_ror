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
    def valid_instance
      @valid_instanse = (
        inst = described_class.create!(title_local: 'Doom')
        inst.cover_image.attach(io: StringIO.new("blah"), filename: 'tmp')
        inst
      )
    end

    it { expect(valid_instance.cover_image).to be_attached }
  end
end
