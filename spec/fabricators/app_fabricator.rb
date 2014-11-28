Fabricator(:app) do
  name 'super-app'
  owner { Fabricate(:user) }
  config_vars { {'super' => 'vars'} }
end
