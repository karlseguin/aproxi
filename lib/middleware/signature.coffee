hashlib = require('hashlib')
utils = require('./utils')

signature = ->
  signature = (request, response, next) ->
    return next() if request._signature
    request._signature = true

    config = request._aproxi.config.signature
    context = request._aproxi.context
    action = if context.action? then context.action else '/'
    keys = config[context.resource]?[context.method]?[action]
    
    return next() unless keys?

    params = if context.method == 'GET' || context.method == 'DELETE' then request.query else request.body
    signature = params['sig']
    return invalid(response) unless signature?

    str = ''
    str += key + '|' + params[key] + '|' for key in keys
    str += context.app.secret + '|' + context.resource.toLowerCase()

    if hashlib.sha1(str) == signature 
      next()
    else
      invalid(response)

invalid = (response) ->
  utils.error(response, 'invalid signature')

    
module.exports = signature