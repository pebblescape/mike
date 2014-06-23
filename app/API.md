API
===

Entire API is JSON

* POST /auth - verify user by public key
  * Params:
    * username
    * key - public key
  * Returns: true or false
* POST /release - create new release
  * Params:
    * app
  * Returns:
    * release_id
* POST /deploy - deploy release
  * Params:
    * app
    * release_id
  * Returns:
    * ?