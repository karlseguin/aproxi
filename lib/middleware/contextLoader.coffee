Context = require('./../context')
utils = require('./utils')

contextLoader =  ->
  contextLoader = (request, response, next) ->
    return next() if request._contextLoader
    request._contextLoader = true

    Context.fromRequest request, (context) ->
      unless context?
        utils.error(response, 'the key is not valid')
      else
        request._context = context
        next()
    

module.exports = contextLoader