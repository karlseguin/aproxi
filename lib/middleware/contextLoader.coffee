utils = require('./utils')

captures = ['version', 'resource', 'action']
contextLoader =  (config) ->
  contextLoader = (request, response, next) ->
    return next() if request._contextLoader
    request._contextLoader = true

    request._context = {url: request.url, method: request.method}
    match = config.routePattern.exec(request.url)
    return next() unless match?
    for capture in captures when config.captures[capture]?
      value = match[config.captures[capture]]
      request._context[capture] = value if value?

    next()
    
module.exports = contextLoader