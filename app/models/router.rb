class Router
  def self.add_dyno(dyno)
    client.set(make_key(app, "endpoints", dyno.ip_address), value: dyno.url)
  end

  def self.remove_dyno(dyno)
    client.delete(make_key(app, "endpoints", dyno.ip_address))
  end

  def self.sync_app(app)
    client.set(make_key(app, "hostname"), value: app.hostname)
    # client.set(make_key(app, "ssl"), value: true)
    # client.set(make_key(app, "sslforce"), value: true)
  end

  private

  def self.client
    Etcd.client
  end

  def self.app_key(app)
    "/pebblescape/apps/#{app.name}"
  end

  def self.make_key(app, *elements)
    ([app_key(app)] << elements).join("/")
  end
end
