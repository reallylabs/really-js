#
# Module dependencies.
#

CONFIG              = require './support/server/config'
protocol            = require '../src/protocol'
ReallyError         = require '../src/really-error'
WebSocketTransport  = require '../src/transports/webSocket'

options =
  heartbeatInterval: 5e3 # 5 seconds
  heartbeatTimeout: 5e3 # 5 seconds

describe 'webSocket', ->

  describe 'initialization', ->

    it 'should construct URL that matches Really URL scheme when domain is passed', ->
      ws = new WebSocketTransport('wss://a6bcc.api.really.io', 'ibj88w5aye', options)
      expect(ws.url).toEqual "wss://a6bcc.api.really.io/v#{protocol.clientVersion}/socket"

    it 'should throw error if initialized without passing domain and access token', ->
      expect ->
        ws = new WebSocketTransport(null, null, options)
      .toThrow new ReallyError('Can\'t initialize connection without passing domain and access token')
      
      expect ->
        ws = new WebSocketTransport('wss://a6bcc.api.really.io', undefined, options)
      .toThrow new ReallyError('Can\'t initialize connection without passing domain and access token')
      
      expect ->
        ws = new WebSocketTransport(undefined, 'ibj88w5aye', options)
      .toThrow new ReallyError('Can\'t initialize connection without passing domain and access token')
      
      expect ->
        ws = new WebSocketTransport(1234, 1234, options)
      .toThrow new ReallyError('Only <String> values are allowed for domain and access token')
      
      expect ->
        ws = new WebSocketTransport('wss://a6bcc.api.really.io', 1234, options)
      .toThrow new ReallyError('Only <String> values are allowed for domain and access token')
  
  describe 'connect', ->

    it 'should initialize @socket only one time (singleton)', ->
      ws = new WebSocketTransport('wss://a6bcc.api.really.io','ibj88w5aye', options)
      ws.connect()
      socket1 = ws.socket
      expect(socket1).toBeDefined()
      ws.connect()
      socket2 = ws.socket
      expect(socket2).toBe(socket1)

    xit 'should trigger error event when server is blocked/not found', (done) ->
      ws = new WebSocketTransport('wss://WRONG_ID.really.io','ibj88w5aye', options)
      connected = true
      ws.connect()
      ws.on 'error', () ->
        connected = false

      setTimeout (->
        expect(connected).toBeFalsy()
        done()
      ), 2000

    it 'should send first message', (done) ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye', options)
      ws.connect()
      message = {tag: 1, 'cmd': 'init', accessToken: 'ibj88w5aye'}
      ws.once 'message', (msg) ->
        expect(message).toEqual msg
        done()

    it 'should check if state of connection is initialized after successful connection (onopen)', (done) ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye', options)
      ws.connect()
      readyState = ws.socket.readyState
      expect(readyState).toEqual ws.socket.CONNECTING
      ws.socket.onopen = ->
        readyState = ws.socket.readyState
        expect(readyState).toEqual ws.socket.OPEN
        done()

    it 'should trigger initialized event with user data, after calling success callback', (done) ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye', options)
      ws.connect()
      ws.on 'initialized', (data) ->
        expect(ws.initialized).toBeTruthy()
        done()

    xit 'should trigger initializationError event when wrong format of initialization message sent', (done) ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5ake', options)
      initializationErrorEventFired = false
      ws.on 'initializationError', () ->
        initializationErrorEventFired = true
      
      ws.connect()
      
      setTimeout (->
        ws.send testCmd: 'give-me-error'
        expect(initializationErrorEventFired).toBeTruthy()
        done()
      ), 1500

  describe 'send', ->

    it 'should raise exception if channel is not connected', ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye', options)
      expect ->
        ws.send(protocol.createMessage('/users'),{})
      .toThrow new ReallyError('Connection to the server is not established')


    it 'should send data with UTF-8 string format with included tag', (done) ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye', options)
      ws.connect()
      message = protocol.createMessage('/users')
      
      ws.socket.onopen = ->
        console.log 'on open'
        spy = spyOn(ws.socket, 'send')
        ws.send(message, {})
        message.data.tag = 1
        
        setTimeout( ->
          expect(spy).toHaveBeenCalledWith(JSON.stringify message.data)
          done()
        , 100)
        


  describe 'disconnect', ->

    it 'should close the websocket transport', (done) ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye', options)
      ws.connect()
      
      ws.socket.onopen = ->
        ws.disconnect()
        expect(ws).toBeNull
        done()


    it 'should set the initialized flag to false', (done) ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye', options)
      ws.connect()
      
      ws.socket.onopen = ->
        setTimeout(->
          expect(ws.initialized).toBeTruthy()
        , 1000)
        
        ws.disconnect()
        expect(ws.initialized).toBeFalsy()
        done()


    it 'should set the socket instance to null', (done) ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye', options)
      ws.connect()
      
      ws.socket.onopen = ->
        ws.disconnect()
        expect(ws.socket).toBeNull
        done()

  describe 'isConnected', ->

    it 'should return false if socket is not initialized', ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye', options)
      ws.connect()
      
      setTimeout (->
        ws.socket = null
        expect(ws.isConnected()).toBeFalsy()
      ), 1000

    it 'should return true if socket is connected/open', (done) ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye', options)
      ws.connect()
      
      ws.socket.onopen = ->
        expect(ws.isConnected()).toBeTruthy()
        done()
