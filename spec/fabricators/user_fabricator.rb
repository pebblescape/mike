Fabricator(:user) do
  login { sequence(:login) { |i| "bwayne#{i}" } }
  email { sequence(:email) { |i| "bruce#{i}@wayne.com" } }
  password 'myawesomepassword'
end

Fabricator(:admin, from: :user) do
  login { sequence(:login) { |i| "aadmin#{i}" } }
  email { sequence(:email) {|i| "anne#{i}@discourse.org"} }
  admin true
end
