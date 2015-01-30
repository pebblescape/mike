require 'docker'

# boot2docker configuration
if ENV['DOCKER_HOST'] && ENV['DOCKER_HOST'].start_with?('tcp:') && ENV['DOCKER_CERT_PATH']
  Excon.defaults[:ssl_verify_peer] = !Rails.env.development?
end
