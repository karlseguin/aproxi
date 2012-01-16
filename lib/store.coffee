Mongo = require('mongodb')
ObjectID = Mongo.BSONPure.ObjectID

class Store
  @idPattern: new RegExp("^[0-9a-fA-F]{24}$")
  constructor: (@db) ->

  insert: (name, document, options, callback) ->
    @db.collection name, (err, collection) ->
      collection.insert(document, options, callback)

  findOne: (name, criteria, options, callback) ->
    unless callback?
      callback = options
      options = {}

    @db.collection name, (err, collection) ->
      collection.findOne criteria, options, (err, result) ->
        callback(null, result)

  idFromString: (value) ->
    if Store.idPattern.test(value) then ObjectID.createFromHexString(value) else null

module.exports.Store = Store
module.exports.initialize = (config, callback) ->
  new Mongo.Db(config.log.database, new Mongo.Server(config.log.host, config.log.port, {})).open (err, logDatabase) ->
    if err?
      callback(err)
      return

    new Mongo.Db(config.app.database, new Mongo.Server(config.app.host, config.app.port, {})).open (err, appDatabase) ->
      if err?
        callback(err)
        return

      module.exports.logStore = new Store(logDatabase)
      module.exports.appStore = new Store(appDatabase)
      callback()