require 'rails_helper'

RSpec.describe Country, type: :model do
  it { should have_db_index :name }
  it { should validate_presence_of :name }
end
