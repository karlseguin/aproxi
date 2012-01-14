

class Cache
  constructor: (expirationInSeconds, pruneInSeconds) ->
    @store = {}
    @expiration = expirationInSeconds * 1000
    pruneInSeconds = 30 unless pruneInSeconds?
    @pruneId = setInterval(this.prune, pruneInSeconds * 1000)

  add: (key, value) ->
    entry = 
      value: value
      created: new Date().getTime()
    @store[key] = entry
    
    return entry

  get: (key, found) ->
    entry = @store[key]
    return null unless entry?

    if this.isExpired(entry)
      delete @store[key]
      return null 

    return entry.value

  isExpired: (entry) ->
    (entry.created + @expiration) < new Date().getTime()

  prune: =>
    delete @store[key] for key of @store when this.isExpired(@store[key])

module.exports = Cache