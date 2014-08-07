Fabricator(:user) do
  name 'Bruce Wayne'
  email { sequence(:email) { |i| "bruce#{i}@wayne.com" } }
  password 'myawesomepassword'
end

Fabricator(:admin, from: :user) do
  name 'Anne Admin'
  email { sequence(:email) {|i| "anne#{i}@discourse.org"} }
  admin true
end