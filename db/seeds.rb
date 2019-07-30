# Country

['USA', 'Russia', 'Italy', 'France'].each do |name|
  Country.create!(name: name) unless Country.find_by name: name
end
