module.exports = 
  site: require('./middleware/site')
  context: require('./middleware/context')
  app: require('./middleware/app')
  bodyParser: require('./middleware/bodyParser')
  upstream: require('./middleware/upstream')