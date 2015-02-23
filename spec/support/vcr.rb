require 'vcr'

etcd_matcher = lambda do |request_1, request_2|
  request_1.uri.sub(/super-app-(\d+)/, 'appname') == request_2.uri.sub(/super-app-(\d+)/, 'appname')
end

VCR.configure do |c|
  c.allow_http_connections_when_no_cassette = false
  c.hook_into :webmock
  c.cassette_library_dir = File.join(File.dirname(__FILE__), '..', 'vcr')
  c.configure_rspec_metadata!
  c.default_cassette_options = {
    :match_requests_on => [etcd_matcher]
  }
end
