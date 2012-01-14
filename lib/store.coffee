Cache = require('./cache')
Mongo = require('mongodb')

instance = null
idPattern = new RegExp("^[0-9a-fA-F]{24}$")

class Store
  constructor: (@log, @app) ->
    @appCache = new Cache(30)
    @appCache.add('test1', {})

  getApp: (key, callback) ->
    unless idPattern.test(key)
      callback(null, null)
      return

    cacheKey = 'app:' + key
    cached = @appCache.get(cacheKey)
    if cached?
      callback(null, cached)
      return

    Store.findOne @app, 'games', {_id: key}, (err, result) ->
      @appCache.add(cacheKey, result)
      callback(null, result)


  @findOne: (db, name, criteria, options, callback) ->
    unless callback?
      callback = options
      options = {}

    options['limit'] = 1
    db.collection name, (err, collection) ->
      collection.find criteria, options, (err, result) ->
        callback(null, result)


module.exports.Store = Store
module.exports.instance = instance
module.exports.initialize = (config, callback) ->
  new Mongo.Db(config.log.database, new Mongo.Server(config.log.host, config.log.port, {})).open (err, logDatabase) ->
    if err?
      callback(err)
      return

    new Mongo.Db(config.app.database, new Mongo.Server(config.app.host, config.app.port, {})).open (err, appDatabase) ->
      if err?
        callback(err)
        return

      instance = new Store(logDatabase, appDatabase)
      callback()