# db/seeds.rb

puts "Creating admin user (sample)"
roger = User.find_or_create_by!(email: "admin@example.com") do |user|
  user.name = "roger"
  user.password = "roger123"
  user.password_confirmation = "roger123"
end

puts "Creating statuses"
status_data = [
  { name: "New", color: "#70728F" },
  { name: "Ready", color: "#45ADFF" },
  { name: "In Progress", color: "#5ADAD1" },
  { name: "Closed", color: "#A95AD5" }
]
status_data.each { |data| Status.create!(data) }

puts "Creating priorities"
priority_data = [
  { name: "Low", color: "#666666" },
  { name: "Normal", color: "#40B829" },
  { name: "High", color: "#E44057" }
]
priority_data.each { |data| Priority.create!(data) }

puts "Creating severities"
severity_data = [
  { name: "Wishlist", color: "#999999" },
  { name: "Minor", color: "#5ADAD1" },
  { name: "Normal", color: "#45ADFF" },
  { name: "Important", color: "#FFA500" },
  { name: "Critical", color: "#E44057" }
]
severity_data.each { |data| Severity.create!(data) }

puts "Creating issue types"
type_data = [
  { name: "Bug", color: "#E44057" },
  { name: "Question", color: "#A95AD5" },
  { name: "Enhancement", color: "#40B829" }
]
type_data.each { |data| IssueType.create!(data) }

puts "Creating tags"
[ "Frontend", "Backend", "Urgente", "Refactor" ].each do |tag_name|
  Tag.create!(name: tag_name, color: "#" + SecureRandom.hex(3))
end

puts "Seeding completed"
