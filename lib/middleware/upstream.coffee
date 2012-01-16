http = require('http')
utils = require('./utils')

proxy = ->
  proxy = (request, response, next) ->
    return next() if request._proxy
    request._proxy = true

    config = request._aproxi.config.upstream
    options = 
      port: config.port
      host: config.host
      method: request.method
      path: request.url
      headers: request.headers

    prequest = http.request options, (presponse) ->
      presponse.on 'data', (chunk) -> response.write(chunk, 'binary')
      presponse.on 'end', -> response.end()
      response.writeHead(presponse.statusCode, presponse.headers);

    prequest.on 'error', (err) ->
      utils.error(response, 'connection to application server refused', 503)
      
    prequest.write(request.bodyRaw, 'binary') if request.bodyRaw
    prequest.end()

module.exports = proxy