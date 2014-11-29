Fabricator(:app) do
  name { sequence(:name) { |i| "super-app-#{i}" } }
  owner { Fabricate(:user) }
  config_vars { {'super' => 'vars'} }
end
