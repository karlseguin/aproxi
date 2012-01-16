config = 
  contextLoader:
    routePattern: /\/v(\d+)\/(\w+)(\/(\w+))?/
    captures: 
      version: 1
      resource: 2
      action: 4
  upstream: 
    port: 3000
    host: '127.0.0.1'

siteLoader = ->
  siteLoader = (request, response, next) ->
    return next() if request._siteLoader
    request._siteLoader = true
    request._aproxi = {config: config}
    next()
    
module.exports = siteLoader