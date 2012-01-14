utils = require('./utils')

bodyParser =  ->
  bodyParser = (request, response, next) ->
    return next() if request._bodyParser
    request._bodyParser = true

    if request.method != "POST" && request.method != "PUT" 
      return next()

    if (request.headers['content-type'] || '').split(';')[0] != 'application/json'
      return utils.error(response, 'invalid content type')

    unless request.headers['content-length']?
      return utils.error(response, 'invalid content length')
      
    
    buffer = new Buffer(parseInt(request.headers['content-length']))
    read = 0
    request.on 'data', (chunk) ->
      chunk.copy(buffer, read)
      read += chunk.length
    request.on 'end', ->
      try
        request.bodyRaw = buffer
        request.body = if buffer.length == 0 then {} else JSON.parse(buffer.toString('utf8'))
        next()
      catch error
        return utils.error(response, 'failed to parse json')
    

module.exports = bodyParser