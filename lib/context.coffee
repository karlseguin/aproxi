store = require('./store').instance

class Context
  constructor: (@app, @method) ->

  @fromRequest: (request, callback) ->
    method = request.method
    key = if method == 'GET' || method == 'DELETE' then request.query['key'] else request.body['key']
    store.getApp key, (err, app) ->
      if err? || !app? 
        callback(null)
      else
        callback(new Context(app, method))
  
module.exports = Context