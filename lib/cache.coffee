## todo run a timer to clear out stale  entries
class Cache
  constructor: (expirationInSeconds) ->
    @store = {}
    @expiration = expirationInSeconds * 1000

  add: (key, value) ->
    entry = 
      value: value
      created: new Date().getTime()
    @store[key] = entry
    
    return entry

  get: (key, found) ->
    entry = @store[key]
    if !entry? || (entry.created + @expiration) < new Date().getTime()
      return null 
    return entry.value


module.exports = Cache