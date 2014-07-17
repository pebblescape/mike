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
end