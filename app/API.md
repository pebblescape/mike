API
===

Entire API is JSON

* POST /auth - verify user by public key
  * Params:
    * username
    * key - public key
  * Returns: user json for success, 404 on failure
* POST /apps/{app}/builds - create build
  * Params:
    * process_types*
    * buildpack_desc
    * commit
    * size
  * Returns:
    * id
* POST /apps/{app}/releases - deploy build
  * Params:
    * build_id*
    * description
  * Returns:
    * version
