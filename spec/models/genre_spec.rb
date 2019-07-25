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
      allow(described_class)
        .to receive(:normalize).with(:value) { 'normalized' }
      expect(->{ subject.name = :value; subject.name }.call)
        .to eq 'normalized'
    end

    it '.normalize' do
      expect(described_class.normalize " вОт  такая \n   строка ")
        .to eq 'вот такая строка'
    end

    it '.find' do
      names = %w[name1 name2 name3]
      names.each do |name|
        allow(described_class).to receive(:normalize).with(name) { name }
      end
      allow(ActiveRecord::Base).to receive(:find).with(*names) { names }
      expect(described_class.find(*names)).to be names
    end

    it '.exists?' do
      allow(described_class).to receive(:normalize).with(:name) { :normalized }
      allow(ActiveRecord::Base).to receive(:exists?)
        .with(:normalized) { :true_or_false }
      described_class.exists?(:name).should eq(:true_or_false)
    end

    describe '.map!' do
      it 'test in mocked context' do
        allow(described_class).to \
          receive(:map)
          .with(:names)
          .and_yield(:_, :nname_val)
          .and_return :mapped_genre
        expect(described_class).to receive(:create).with(name: :nname_val)
        expect(described_class.map!(:names)).to eq(:mapped_genre)
      end

      it 'test in real db' do
        names = %w[Name1 Name2 Name3]
        expect(described_class.map!(names).map(&:name).sort).to \
          eq(names.map(&:downcase))
      end
    end

    describe '.map' do
      it 'test in mocked context' do
        names = %w[Name1 Name2]
        names.each do |name|
          expect(described_class).to \
            receive(:normalize).with(name) { name.downcase }
          expect(described_class).to \
            receive(:exists?).with(name.downcase) { false }
        end
        described_class.map(names) do |name, nname|
          [name, nname]
        end.should eq [['Name1', 'name1'], ['Name2', 'name2']]
      end

      it 'yields if only normalized name do not empty' do
        described_class.map([' ', nil, '']) do
          assert false, 'Unexpected yielding'
        end.should eq []
      end

      it 'test in real db' do
        genres = 3.times.to_a.map do |i|
          described_class.create(name: "Genre#{i}")
        end
        described_class.map(genres.map(&:name)).should eq genres
      end
    end
  end
end
