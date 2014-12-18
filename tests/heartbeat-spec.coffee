Heartbeat  = require '../src/heartbeat'
Q = require 'q'
channel = require '../src/transports/webSocket'

describe 'Heartbeat', ->
  describe 'initialization', ->
    jasmine.DEFAULT_TIMEOUT_INTERVAL = 660000
    it 'tests initialize', (done) ->
      hb = new Heartbeat()
      c = new channel('ws://localhost:1337', 'dasdasd', {})
      c.connect()
      c.on 'initialized', () ->
        hb.start(c)
      
      setTimeout(->
        expect(true).toBeTruthy()
        done()
      , 60000)  
      
    
