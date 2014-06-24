# Fabricator(:user) do
#   name 'Bruce Wayne'
#   username { sequence(:username) { |i| "bruce#{i}" } }
#   email { sequence(:email) { |i| "bruce#{i}@wayne.com" } }
#   password 'myawesomepassword'
#   ip_address { sequence(:ip_address) { |i| "99.232.23.#{i%254}"} }
# end
