Context = require('./../context')
utils = require('./utils')

contextLoader =  (config) ->
  contextLoader = (request, response, next) ->
    return next() if request._contextLoader
    request._contextLoader = true
    Context.fromRequest request, config, (context) ->
      if context?
        request._context = context
        return next()
      
      utils.error(response, 'the key is not valid')
    

module.exports = contextLoader