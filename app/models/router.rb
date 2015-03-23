class Router
  def self.add_dyno(dyno)
    client.set(make_key(dyno.app, 'endpoints', dyno.ip_address), dyno.server)
  end

  def self.remove_dyno(dyno)
    client.del(make_key(dyno.app, 'endpoints', dyno.ip_address))
  end

  def self.sync_app(app)
    client.set(make_key(app, 'hostname'), app.hostname)
    # client.set(make_key(app, 'ssl'), true)
    # client.set(make_key(app, 'sslforce'), true)
  end

  def self.client
    $redis
  end

  def self.app_key(app)
    "/pebblescape/apps/#{app.name}"
  end

  def self.make_key(app, *elements)
    ([app_key(app)] << elements).join('/')
  end
end
