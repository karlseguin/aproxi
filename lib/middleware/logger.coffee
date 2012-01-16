store = require('./../store').logStore
utils = require('./utils')

logger = ->
  logger = (request, response, next) ->
    return next() if request._logger
    request._logger = true

    start = utils.Date().getTime()
    end = response.end
    response.end = (chunk, encoding) ->
      response.end = end
      response.end(chunk, encoding)

      context = request._aproxi.context
      document = 
        app: context.app?._id
        method: context.method
        version: context.version
        resource: context.resource
        action: context.action
        status: response.statusCode
        time: utils.Date().getTime() - start
      store.insert('proxy_logs', document)

    next()
    
module.exports = logger