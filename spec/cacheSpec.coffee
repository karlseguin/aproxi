helper = require('./helper')
Cache = helper.require('./lib/cache')

cache = null
describe 'cache', ->
  afterEach -> clearInterval(cache.pruneId)

  it "caches the item", ->
    cache = new Cache(10000)
    cache.put('leto', {likes: 'spice'})
    expect(cache.get('leto', null)).toEqual({likes: 'spice'})
    
  it "caches multiple item", ->
    cache = new Cache(10000)
    cache.put('leto', {likes: 'spice'})
    cache.put('paul', {likes: 'chani'})
    expect(cache.get('leto', null)).toEqual({likes: 'spice'})
    expect(cache.get('paul', null)).toEqual({likes: 'chani'})    

  it "same key overwrites existing cached value", ->
    cache = new Cache(10000)
    cache.put('leto', {likes: 'spice'})
    cache.put('leto', {likes: 'Hwi'})
    expect(cache.get('leto', null)).toEqual({likes: 'Hwi'})

  it "miss return undefined", ->
    cache = new Cache(10000)
    expect(cache.get('leto')).toBeUndefined()

  it "expired returns null", ->
    cache = new Cache(-1000000)
    cache.put('leto', 999)
    expect(cache.get('leto')).toBeNull()
    expect(cache.store).toEqual({})