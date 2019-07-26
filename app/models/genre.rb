class Genre < ApplicationRecord
  validates :name, presence: true
  has_and_belongs_to_many :movies, foreign_key: :genre_name

  def name=(val)
    super self.class.normalize(val)
  end

  def self.map(names)
    names.map do |name|
      nname = normalize name
      next if nname.empty?
      if exists? nname
        find nname
      elsif block_given?
        yield name, nname
      end
    end.compact
  end

  def self.map!(names)
    map(names) do |_, nname|
      Genre.create(name: nname)
    end
  end

  def self.find(*names)
    super(*names.map { |val| normalize val })
  end

  def self.exists?(name)
    super normalize(name)
  end

  def self.normalize(str)
    str.to_s.gsub(/[\n\r]/, ' ').gsub(/\s+/, ' ').strip.downcase
  end
end

