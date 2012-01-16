store = require('./../store').logStore

logger = ->
  logger = (request, response, next) ->
    return next() if request._logger
    request._logger = true

    end = response.end
    response.end = (chunk, encoding) ->
      response.end = end
      response.end(chunk, encoding)
    next()
    
module.exports = siteLoader