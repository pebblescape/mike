require 'docker'

# boot2docker configuration
if ENV['DOCKER_HOST'] && ENV['DOCKER_HOST'].start_with?('tcp:') && ENV['DOCKER_CERT_PATH']
  cert_path = File.expand_path ENV['DOCKER_CERT_PATH']
  Docker.options = {
    client_cert: File.join(cert_path, 'cert.pem'),
    client_key: File.join(cert_path, 'key.pem'),
    scheme: 'https'
  }

  Excon.defaults[:ssl_ca_file] = File.join(cert_path, 'ca.pem')
end