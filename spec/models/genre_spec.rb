require 'rails_helper'

describe Genre, type: :model do
  describe 'validators' do
    it { should validate_presence_of :name }
    it { expect { subject.save! }.to raise_error /Name can't be blank/ }
  end

  describe 'schema' do
    it { expect(described_class.primary_key).to eq 'name' }
  end

  describe 'helpers' do
    it '#name= normalize value' do
      expect(described_class)
        .to receive(:normalize).with('value') { 'normalized' }
      expect(->{ subject.name = :value; subject.name }.call)
        .to eq 'normalized'
    end

    it '.normalize' do
      expect(described_class.normalize " вОт  такая \n   строка ")
        .to eq 'вот такая строка'
    end

    it '.map array of strings on array of instances' do
      skip "FIXME"
#       input = %w{name1 name2 name3}
#       expect(described_class).to receive(:normalize)
#         .with(name: ) {}
#       described_class.map(%w{name1 name2 name3}).should be [instanse(:name1)]
    end
  end
end
