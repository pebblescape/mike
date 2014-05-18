Fabricator(:user) do
  name 'Bruce Wayne'
  username { sequence(:username) { |i| "bruce#{i}" } }
  email { sequence(:email) { |i| "bruce#{i}@wayne.com" } }
  password 'myawesomepassword'
  ip_address { sequence(:ip_address) { |i| "99.232.23.#{i%254}"} }
end

Fabricator(:coding_horror, from: :user) do
  name 'Coding Horror'
  username 'CodingHorror'
  email 'jeff@somewhere.com'
  password 'mymoreawesomepassword'
end

Fabricator(:evil_trout, from: :user) do
  name 'Evil Trout'
  username 'eviltrout'
  email 'eviltrout@somewhere.com'
  password 'imafish'
end

Fabricator(:walter_white, from: :user) do
  name 'Walter White'
  username 'heisenberg'
  email 'wwhite@bluemeth.com'
  password 'letscook'
end

Fabricator(:admin, from: :user) do
  name 'Anne Admin'
  username { sequence(:username) {|i| "anne#{i}"} }
  email { sequence(:email) {|i| "anne#{i}@discourse.org"} }
  admin true
end

Fabricator(:newuser, from: :user) do
  name 'Newbie Newperson'
  username 'newbie'
  email 'newbie@new.com'
end

Fabricator(:leader, from: :user) do
  name 'Leader McLeaderman'
  username { sequence(:username) { |i| "leader#{i}" } }
  email { sequence(:email) { |i| "leader#{i}@leaderfun.com" } }
end

Fabricator(:elder, from: :user) do
  name 'Elder McElderson'
  username { sequence(:username) { |i| "elder#{i}" } }
  email { sequence(:email) { |i| "elder#{i}@elderfun.com" } }
end