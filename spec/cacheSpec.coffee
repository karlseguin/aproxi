helper = require('./helper')
Cache = helper.require('./lib/cache')

describe 'cache', ->
  it "caches the item", ->
    cache = new Cache(10000)
    cache.add('leto', {likes: 'spice'})
    expect(cache.get('leto', null)).toEqual({likes: 'spice'})
    
  it "caches multiple item", ->
    cache = new Cache(10000)
    cache.add('leto', {likes: 'spice'})
    cache.add('paul', {likes: 'chani'})
    expect(cache.get('leto', null)).toEqual({likes: 'spice'})
    expect(cache.get('paul', null)).toEqual({likes: 'chani'})    

  it "same key overwrites existing cached value", ->
    cache = new Cache(10000)
    cache.add('leto', {likes: 'spice'})
    cache.add('leto', {likes: 'Hwi'})
    expect(cache.get('leto', null)).toEqual({likes: 'Hwi'})

  it "miss return null", ->
    cache = new Cache(10000)
    expect(cache.get('leto')).toBeNull()

  it "expired returns null", ->
    cache = new Cache(-1000000)
    cache.add('leto', 999)
    expect(cache.get('leto')).toBeNull()