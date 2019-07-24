class Genre < ApplicationRecord
  validates :name, presence: true

  def name=(val)
    super self.class.normalize(val.to_s)
  end

  def self.normalize(str)
    str.gsub(/[\n\r]/, ' ').gsub(/\s+/, ' ').strip.downcase
  end
end
