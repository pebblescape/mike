class Router
  def self.add_dyno(dyno)
    client.set(make_key(dyno.app, 'endpoints', dyno.ip_address), value: dyno.server)
  end

  def self.remove_dyno(dyno)
    client.delete(make_key(dyno.app, 'endpoints', dyno.ip_address))
  rescue Etcd::KeyNotFound
  end

  def self.sync_app(app)
    client.set(make_key(app, 'hostname'), value: app.hostname)
    # client.set(make_key(app, 'ssl'), value: true)
    # client.set(make_key(app, 'sslforce'), value: true)
  end

  def self.client
    Etcd.client(host: ENV['ETCD_HOST'] || 'localhost', port: 4001)
  end

  def self.app_key(app)
    "/pebblescape/apps/#{app.name}"
  end

  def self.make_key(app, *elements)
    ([app_key(app)] << elements).join('/')
  end
end
