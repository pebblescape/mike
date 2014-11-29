Fabricator(:build) do
  status { Build.status_types[:pending] }
  buildpack_description "Ruby/Rack"
  commit { SecureRandom.hex(20) }
  process_types { {"web" => "bundle exec puma"} }
  size 20971520
end
