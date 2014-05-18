module Helpers
  def log_in(fabricator=nil)
    user = Fabricate(fabricator || :user)
    log_in_user(user)
    user
  end

  def log_in_user(user)
    provider = Mike.current_user_provider.new(request.env)
    provider.log_on_user(user,session,cookies)
  end

  def fixture_file(filename)
    return '' if filename.blank?
    file_path = File.expand_path(Rails.root + 'spec/fixtures/' + filename)
    File.read(file_path)
  end

  def build(*args)
    Fabricate.build(*args)
  end

  def generate_username(length=10)
    range = [*'a'..'z']
    Array.new(length){range.sample}.join
  end
end
