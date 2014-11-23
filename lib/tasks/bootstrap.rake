require "highline/import"

namespace :bootstrap do
  def title(msg)
    say "<%= color('#{msg}', :green) %>"
  end
  
  task :users => :environment do
    title "Creating system user"
    unless Mike.system_user
      User.create!(id: Mike::SYSTEM_USER_ID, name: 'system', email: 'no_email', password: SecureRandom.hex, active: true, admin: true)
      title "Creating master API key"
      master_key = ApiKey.create_master_key
      say "<%= color('#{master_key.key}', :yellow) %>"
    end
    
    title "Setting up default admin"
    name = ask "Admin name: "
    email = ask "Admin email: "
    password = ask("Admin password: ")  { |q| q.echo = 'x' }
    
    user = User.create!(name: name, email: email, password: password, admin: true, active: true)
    title "Admin created"
    say "<%= color('#{user.inspect}', :yellow) %>"
    
    title "Adding SSH key"
    key = ask("Paste your public key in: ") { |q| q.echo = false }
    sshkey = SshKey.create!(user: user, key: key)
    say "<%= color('#{sshkey.fingerprint}', :yellow) %>"
    
    title "Generating admin API key"
    apikey = user.generate_api_key(Mike.system_user)
    say "<%= color('#{apikey.key}', :yellow) %>"
  end
end