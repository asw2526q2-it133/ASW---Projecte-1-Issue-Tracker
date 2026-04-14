# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# db/seeds.rb

puts "Netejant dades antigues..."
# Opcional: Status.destroy_all etc. si vols fer un reset total cada cop.

puts "Creant Estats..."
['New', 'In Progress', 'Resolved', 'Feedback', 'Closed', 'Rejected'].each do |name|
  Status.find_or_create_by!(name: name) do |s|
    s.color = case name
              when 'New' then '#3498db'        # Blau
              when 'In Progress' then '#f1c40f' # Groc
              when 'Resolved' then '#2ecc71'   # Verd
              when 'Closed' then '#95a5a6'     # Gris
              else '#e74c3c'                   # Vermell
              end
  end
end

puts "Creant Prioritats..."
['Low', 'Normal', 'High', 'Urgent'].each do |name|
  Priority.find_or_create_by!(name: name) do |p|
    p.color = case name
              when 'Low' then '#bdc3c7'
              when 'High' then '#e67e22'
              when 'Urgent' then '#c0392b'
              else '#27ae60'
              end
  end
end

puts "Creant Tipus d'Issue..."
['Bug', 'Feature', 'Support', 'Task'].each do |name|
  Type.find_or_create_by!(name: name) do |t|
    t.color = '#34495e'
  end
end

puts "Creant Severitats..."
['Wishlist', 'Minor', 'Normal', 'Major', 'Critical', 'Blocker'].each do |name|
  Severity.find_or_create_by!(name: name) do |s|
    s.color = (name == 'Blocker' || name == 'Critical') ? '#8e44ad' : '#7f8c8d'
  end
end

puts "Creant Tags bàsics..."
['Frontend', 'Backend', 'API', 'Design', 'Urgent'].each do |name|
  Tag.find_or_create_by!(name: name, color: '#16a085')
end

# CREACIÓ D'UN USUARI DE PROVA (Opcional)
# Com que fas servir Google OAuth, el UID normalment vindria de Google, 
# però en creem un manual per poder fer proves de relacions.
test_user = User.find_or_create_by!(email: "test@example.com") do |u|
  u.name = "Usuari de Prova"
  u.uid = "123456789"
  u.avatar_url = "https://via.placeholder.com/150"
end

puts "Creant una Issue de mostra..."
Issue.find_or_create_by!(subject: "Primera tasca del projecte") do |i|
  i.description = "Aquesta és una issue generada pel seed per comprovar que tot funciona."
  i.creator = test_user
  i.status = Status.find_by(name: 'New')
  i.priority = Priority.find_by(name: 'Normal')
  i.type = Type.find_by(name: 'Task')
  i.severity = Severity.find_by(name: 'Normal')
end

puts "--- SEED FINALITZAT AMB ÈXIT ---"