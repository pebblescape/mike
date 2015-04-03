class DashboardIndex
  def self.latest_version
    html = open("http://pebblescape.s3.amazonaws.com/index.html").read
    ref = html.match(/<!-- REF: (.+) -->/)
    ref[1]
  end

  def self.current_version
    Rails.cache.read('dashboardindex-ref')
  end

  def self.cache_latest(version)
    name = version == 'master' ? 'index.html' : "index.#{version}.html"
    key = "dashboardindex-#{version}"
    html = open("http://pebblescape.s3.amazonaws.com/#{name}").read
    Rails.cache.write(key, html, expires_in: 6.months, race_condition_ttl: 10)
    if version == 'master'
      ref = html.match(/<!-- REF: (.+) -->/)
      Rails.cache.write('dashboardindex-ref', ref[1], expires_in: 6.months, race_condition_ttl: 10)
    end

    html
  end
end
