require 'net/http'
require 'digest/md5'
require 'base64'
require 'json'
require 'excon'

module MikeHelpers
  def get_user(auth={})
    res = get("/user", {}, auth)
    return nil unless res.status == 200
    JSON.parse(res.body)
  end

  def get_app(app, auth={})
    res = get("/apps/#{app}", {}, auth)
    return nil unless res.status == 200
    JSON.parse(res.body)
  end

  def post_push(app, commit, cid)
    data = { "cid" => cid, "build" => { "commit" => commit } }
    res = post("/apps/#{app['id']}/push", data)
    return res.body unless res.status == 200
    JSON.parse(res.body)
  end

  # HTTP methods

  def endpoint
    "http://localhost:5000"
  end

  def headers
    {
      'Accept'                => 'application/vnd.pebblescape+json; version=1',
      'Content-Type'          => 'application/json',
      'Accept-Encoding'       => 'gzip',
      'User-Agent'            => 'pebblescape-receiver',
      'X-Ruby-Version'        => RUBY_VERSION,
      'X-Ruby-Platform'       => RUBY_PLATFORM
    }
  end

  def auth_query(query)
    auth = {
      'api_key' => ENV['HOOK_ENV'],
      'api_login' => ENV['REMOTE_USER']
    }
    query.merge(auth)
  end

  def get(path, query={}, auth={})
    qry = auth.empty? ? auth_query(query) : query.merge(auth)
    Excon.get(endpoint, headers: headers, path: path, query: qry)
  end

  def post(path, body={})
    Excon.new(endpoint, headers: headers).request(
      method: :post,
      path: path,
      query: auth_query({}),
      body: body.to_json
    )
  end
end
