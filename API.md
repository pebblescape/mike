API
===

Entire API is JSON

* POST /auth - verify user by public key
  * Params:
    * username
    * key - public key
  * Returns: user json for success, 404 on failure
* POST /apps/{app}/builds - create build (slug)
  * Params:
    * process_types - {"web":"./bin/web -p $PORT"}
    * buildpack_desc - "Ruby/Rack"
    * commit - "60883d9e8947a57e04dc9124f25df004866a2051"
    * size - 2048
  * Returns:
    * id
* POST /apps/{app}/releases - create release (deploy slug, config, addons)
  * Params:
    * build_id*
    * description
  * Returns:
    * version
