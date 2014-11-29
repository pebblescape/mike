module Helpers
  def fixture_file(filename)
    return '' if filename.blank?
    file_path = File.expand_path(Rails.root + 'spec/fixtures/' + filename)
    File.read(file_path)
  end

  def build(*args)
    Fabricate.build(*args)
  end

  def api_header(version = '1')
    {'Accept' => "application/vnd.pebblescape+json; version=#{version}"}
  end

  def auth_key(user=nil)
    user ||= Fabricate(:admin)
    key = user.api_key || Fabricate(:api_key, user: user)
    {'api_key' => key.key}
  end

  def log_in(fabricator=nil)
    user = Fabricate(fabricator || :user)
    log_in_user(user)
    user
  end

  def log_in_user(user)
    provider = Mike.current_user_provider.new(request.env)
    provider.log_on_user(user,session,cookies)
  end

  def authenticated_request(method, action, params={}, user=nil)
    send(method, action, auth_key(user).merge(params), api_header)
  end
end
