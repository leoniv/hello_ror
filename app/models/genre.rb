class Genre < ApplicationRecord
  validates :name, presence: true

  def name=(val)
    super self.class.normalize(val)
  end

  def self.map(*names)
    names.map do |name|
      nname = normalize name
      if exists? nname
        find nname
      elsif !nname.empty? && block_given?
        yield name, nname
      end
    end.compact
  end

  def self.map!(*names)
    map(*names) do |_, nname|
      create(name: nname)
    end
  end

  def self.find(*names)
    super *names.map {|val| normalize val}
  end

  def self.exists?(name)
    super normalize(name)
  end

  def self.normalize(str)
    str.to_s.gsub(/[\n\r]/, ' ').gsub(/\s+/, ' ').strip.downcase
  end
end
