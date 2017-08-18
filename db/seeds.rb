require 'faker'

def self.color_formulation(combinations)
  
  formula_items = {
    shade: [ '1N', '2N', '3N', '4N', '5N', '6N', '7N', '8N', '9N', '10N'],
    tone: ['Dk B/G', 'Dk B/V', 'Dk Y/O', 'Lt B/B', 'Lt Y/O', 'Lt V/B'],
    weight: ['1g', '2g', '3g', '4g', '5g', '6g', '7g', '8g', '9g', '10g', '15g', '20g', '25g'],
    developer: [ '10vol', '20vol', '30vol', '40vol' ]
  }
  
  result = []
  combinations.times do
    result << formula_items[:weight][rand( formula_items[:weight].size - 1)] + " " + formula_items[:shade][rand( formula_items[:shade].size - 1)]
    result << formula_items[:weight][rand( formula_items[:weight].size - 1)] + " " + formula_items[:tone][rand( formula_items[:tone].size - 1)]
  end
  result << formula_items[:developer][rand( formula_items[:developer].size - 1)]
  
  result.join(" + ")
end

def self.service
  
  service_type = [
  "One Step Color",
  "Spot Foil",
  "Partial Foil",
  "Full Foil",
  "Spot Balayage",
  "Partial Balayage",
  "Full Balayage",
  "Spot Foil & One Step Color",
  "Partial Foil & One Step Color",
  "Full Foil & One Step Color",
  "Spot Balayage & One Step Color",
  "Partial Balayage & One Step Color",
  "Full Balayage & One Step Color"
  ]
  
  service_type[rand(service_type.count - 1)]
end

# build clients
20.times do 
  first_name = Faker::Name.first_name
  last_name = Faker::Name.last_name
  email = Faker::Internet.email(first_name + "_" + last_name)
  password = "password"
  
  User.create!(email: email, first_name: first_name, last_name: last_name, password: password, password_confirmation: password)
end

# build artists
7.times do
  
  first_name = Faker::Name.first_name
  last_name = Faker::Name.last_name
  email = Faker::Internet.email(first_name + "_" + last_name)
  password = "password"
  
  User.create!(email: email, first_name: first_name, last_name: last_name, role: 1, password: password, password_confirmation: password)
end

clients = User.where(role: 0)
artists = User.where(role: 1)

# create connections
30.times do
  client = clients.sample
  artist = artists.sample
  
  unless SalonConnection.where(user_id: artist.id, salon_user_id: client.id).exists?
    SalonConnection.create!(user_id: artist.id, salon_user_id: client.id)
  end
  
end

connections = SalonConnection.all

# create formulas
30.times do
  
  connection = connections.sample
  author = User.find(connection.user_id)
  client = User.find(connection.salon_user_id)
  formulation = color_formulation(rand(1..3))
  service_type = service
  
  author.guest_formulas.create!(
    client_id: connection.salon_user_id,
    salon_connection_id: connection.id,
    formulation: formulation,
    service_type: service_type,
    author_name: author.full_name,
    client_name: client.full_name
    )
  
end

puts "generated #{clients} clients."
puts "generated #{artists} artists."
puts "generated #{SalonConnection.all.size} artist/guest combinations."
puts "generated #{Formula.all.size} formulas."