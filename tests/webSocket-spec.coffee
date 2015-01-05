#
# Module dependencies.
#

CONFIG              = require './support/server/config'
protocol            = require '../src/protocol'
ReallyError         = require '../src/really-error'
WebSocketTransport  = require '../src/transports/webSocket'
CallbacksBuffer     = require '../src/callbacks-buffer'

options =
  reconnectionMaxTimeout: 30e3
  heartbeatTimeout: 3e3
  heartbeatInterval: 5e3
  reconnect: true
  onDisconnect: 'buffer'

describe 'webSocket', ->

  describe 'initialization', ->

    it 'should construct URL that matches Really URL scheme when domain is passed', ->
      ws = new WebSocketTransport('wss://a6bcc.api.really.io', 'ibj88w5aye', options)
      expect(ws.url).toEqual "wss://a6bcc.api.really.io/v#{protocol.clientVersion}/socket"

    it 'should initialize socket', ->
      ws = new WebSocketTransport('wss://a6bcc.api.really.io', 'ibj88w5aye', options)
      expect(ws.socket).toBeNull()

    it 'should initialize callbacks buffer', ->
      ws = new WebSocketTransport('wss://a6bcc.api.really.io', 'ibj88w5aye', options)
      expect(ws.callbacksBuffer).toEqual new CallbacksBuffer()

    it 'should initialize messages buffer', ->
      ws = new WebSocketTransport('wss://a6bcc.api.really.io', 'ibj88w5aye', options)
      expect(ws._messagesBuffer).toEqual []

    it 'should set initialized to false', ->
      ws = new WebSocketTransport('wss://a6bcc.api.really.io', 'ibj88w5aye', options)
      expect(ws.initialized).toBeFalsy()

    it 'should put appropriate default values for options if not supplied', ->
      defaultValues =
        reconnectionMaxTimeout: 30e3
        heartbeatTimeout: 2e3
        heartbeatInterval: 5e3
        reconnect: true
        onDisconnect: 'buffer'

      options0 = {}
      ws = new WebSocketTransport('wss://a6bcc.api.really.io', 'ibj88w5aye', options0)
      expect(ws.options).toEqual defaultValues

      options1 =
        reconnectionMaxTimeout: 25e3

      ws1 = new WebSocketTransport('wss://a6bcc.api.really.io', 'ibj88w5aye', options1)
      expect(ws1.options).toEqual options1

      options2 =
        reconnectionMaxTimeout: 25e3
        heartbeatTimeout: 4e3
      
      ws2 = new WebSocketTransport('wss://a6bcc.api.really.io', 'ibj88w5aye', options2)
      expect(ws2.options).toEqual options2

      options3 =
        reconnectionMaxTimeout: 25e3
        heartbeatTimeout: 4e3
        heartbeatInterval: 4e3
      
      ws3 = new WebSocketTransport('wss://a6bcc.api.really.io', 'ibj88w5aye', options3)
      expect(ws3.options).toEqual options3

      options4 =
        reconnectionMaxTimeout: 25e3
        heartbeatTimeout: 4e3
        heartbeatInterval: 4e3
        reconnect: false
      
      ws4 = new WebSocketTransport('wss://a6bcc.api.really.io', 'ibj88w5aye', options4)
      expect(ws4.options).toEqual options4

      options5 =
        reconnectionMaxTimeout: 25e3
        heartbeatTimeout: 4e3
        heartbeatInterval: 4e3
        reconnect: false
        onDisconnect: 'final'

      ws5 = new WebSocketTransport('wss://a6bcc.api.really.io', 'ibj88w5aye', options5)
      expect(ws5.options).toEqual options5


    it 'should fire events per each instance', ->
      emitter1 = false
      ws1 = new WebSocketTransport('wss://a6bcc.api.really.io', 'ibj88w5aye', options)
      ws1.on 'test', ->
        emitter1 = true
      
      ws1.emit 'test'

      emitter2 = false
      ws2 = new WebSocketTransport('wss://a6bcc.api.really.io', 'ibj88w5aye', options)
      ws2.on 'test', ->
        emitter2 = true

      ws2.emit 'test'

      expect(emitter1).toBeTruthy()
      expect(emitter2).toBeTruthy()

  describe 'connect', ->

    it 'should initialize socket when try to connect with different domain and token', ->
      ws1 = new WebSocketTransport('wss://r5crcc.api.really.io','ibj88w5aye', options)
      ws1.connect()
      socket1 = ws1.socket
      expect(socket1).toBeDefined()
      ws2 = new WebSocketTransport('wss://r5crbb.api.really.io','ibj88w5aye', options)
      ws2.connect()
      socket2 = ws2.socket
      expect(socket2).not.toBe(socket1)
      ws1.disconnect()
      ws2.disconnect()

    it 'should trigger error event when server is blocked/not found', (done) ->
      ws = new WebSocketTransport('wss://WRONG_ID.really.com','ibj88w5aye', options)
      connected = true
      ws.connect()
      ws.on 'error', () ->
        connected = false

      setTimeout (->
        expect(connected).toBeFalsy()
        ws.disconnect()
        done()
      ), 2000

    it 'should send first message', (done) ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye', options)
      ws.connect()
      message = {tag: 1, 'cmd': 'init', accessToken: 'ibj88w5aye'}
      ws.on 'message', (msg) ->
        expect(message).toEqual msg
        ws.disconnect()
        done()

    it 'should trigger initialized event with user data, after calling success callback', (done) ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye', options)
      ws.connect()
      ws.on 'initialized', (data) ->
        expect(ws.initialized).toBeTruthy()
        ws.disconnect()
        done()

    
    it 'should return a promise', ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5ake', options)
      promise = ws.connect()
      expect(typeof promise.then is 'function').toBeTruthy()
      ws.disconnect()

    describe 'connection open', ->
      it 'should initialize reconnectiong attempts number to zero', (done) ->
        ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5ake', options)
        ws.connect()
        ws.socket.addEventListener 'open', () ->
          expect(ws.attempts).toEqual 0
          ws.disconnect()
          done()

      it 'should reslove a promise when connection open', (done) ->
        ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5ake', options)
        promise = ws.connect()
        ws.socket.addEventListener 'open', () ->
          promise.done( (data) ->
            expect(true).toBeTruthy()
            ws.disconnect()
            done()
          , null)

      it 'should send first message when connection open', (done) ->
        ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5ake', options)
        spyOn(ws, 'send').and.callThrough()
        spyOn(protocol, 'initializationMessage').and.callThrough()
        ws.connect()

        ws.socket.addEventListener 'open', () ->
          expect(ws.send).toHaveBeenCalled()
          expect(protocol.initializationMessage).toHaveBeenCalledWith(ws.accessToken)
          ws.disconnect()
          done()

      it 'should fire "opened" event when connection open', (done) ->
        ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5ake', options)
        ws.connect()
        spyOn(ws, 'emit').and.callThrough()
        ws.socket.addEventListener 'open', () ->
          expect(ws.emit).toHaveBeenCalledWith 'opened'
          ws.disconnect()
          done()

    describe 'connection error', ->
      it 'should fire "error" event', (done) ->
        ws = new WebSocketTransport('wss://WRONG_ID.really.com', 'ibj88w5ake', options)
        ws.connect()
        spyOn(ws, 'emit').and.callThrough()
        ws.socket.addEventListener 'error', () ->
          expect(ws.emit).toHaveBeenCalledWith 'error'
          ws.disconnect()
          done()

    describe 'connection message', ->
      it 'should fire "message" event', (done) ->
        ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5ake', options)
        ws.connect()
        spyOn(ws, 'emit').and.callThrough()
        ws.socket.addEventListener 'message', (e) ->
          data = JSON.parse e.data
          expect(ws.emit).toHaveBeenCalledWith 'message', data
          ws.disconnect()
          done()

      it 'should handle buffered message callbacks if it has a tag', (done) ->
        ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5ake', options)
        ws.connect()
        ws.socket.addEventListener 'open', () ->
          message = protocol.createMessage('/users')
          ws.send(message, {})
        spyOn(ws.callbacksBuffer, 'handle').and.callThrough()
        ws.socket.addEventListener 'message', (e) ->
          expect(ws.callbacksBuffer.handle).toHaveBeenCalledWith JSON.parse e.data
          ws.disconnect()
          done()

    describe 'connection close', ->
      it 'should fire "reconnecting" event when reconnect options is true', (done) ->
        ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5ake', options)
        ws.connect()
        spyOn(ws, 'emit').and.callThrough()
        ws.socket.addEventListener 'close', () ->
          expect(ws.emit).toHaveBeenCalledWith 'reconnecting'
          ws.disconnect()
          done()
        ws.socket.close()

      it 'should reconnect when reconnect option is true', (done) ->
        ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5ake', options)
        ws.connect()
        spyOn(ws, 'reconnect').and.callThrough()
        ws.socket.addEventListener 'close', () ->
          expect(ws.reconnect).toHaveBeenCalled()
          ws.disconnect()
          done()
        ws.socket.close()

      it 'should fire "close" event when reconnect options is false', (done) ->
        newOptions =
          reconnect: false
        ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5ake', newOptions)
        ws.connect()
        spyOn(ws, 'emit').and.callThrough()
        ws.socket.addEventListener 'close', () ->
          expect(ws.emit).toHaveBeenCalledWith 'closed'
          ws.disconnect()
          done()
        ws.socket.close()

      it 'should disconnect when reconnect option is false', (done) ->
        newOptions =
          reconnect: false
        ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5ake', newOptions)
        ws.connect()
        spyOn(ws, 'disconnect').and.callThrough()
        ws.socket.addEventListener 'close', () ->
          expect(ws.disconnect).toHaveBeenCalled()
          ws.disconnect()
          done()
        ws.socket.close()

  describe 'send', ->
    describe 'channel connected', ->

      it 'should send message with tag', (done) ->
        ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5ake', options)
        ws.connect()
        spyOn(ws.socket, 'send').and.callThrough()
        ws.socket.addEventListener 'open', () ->

          ws.send(protocol.createMessage('/users'), {})
          expect(ws.socket.send).toHaveBeenCalled()
          ws.disconnect()
          done()

      it 'should buffer message callbacks', (done) ->
        ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5ake', options)
        ws.connect()
        message = protocol.createMessage('/users')
        {kind} = message
        
        success = (data) -> 'success'
        error = (reason) -> 'error'
        complete = (data) -> 'complete'

        ws.socket.addEventListener 'open', () ->
          spyOn(ws.callbacksBuffer, 'add').and.callThrough()
          ws.send(message, {success, error, complete})
          expect(ws.callbacksBuffer.add).toHaveBeenCalled()
          ws.disconnect()
          done()

      it 'should send string message with tag', (done) ->
        ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5ake', options)
        ws.connect()
        message = protocol.createMessage('/users')

        ws.socket.addEventListener 'open', () ->
          spyOn(ws.socket, 'send').and.callThrough()
          ws.send(message, {})

          expect(ws.socket.send).toHaveBeenCalledWith JSON.stringify message.data
          ws.disconnect()
          done()

      it 'should return promise', (done) ->
        ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5ake', options)
        ws.connect()
        message = protocol.createMessage('/users')
        ws.socket.addEventListener 'open', () ->
          promise = ws.send(message, {})
          expect(typeof promise.then is 'function').toBeTruthy()
          ws.disconnect()
          done()

      it 'should reslove the promise when success callback occurs', (done) ->
        ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5ake', options)
        ws.connect()
        message = protocol.createMessage('/users')
        successfulMessage = false
        
        success = (data) -> successfulMessage = data
        error = (reason) -> 'error'
        complete = (data) -> 'complete'

        promise = ws.send(message, {success, error, complete})
        promise.done (e) ->
          expect(successfulMessage).toEqual e
          ws.disconnect()
          done()

      it 'should reject the promise when error callback occurs', (done) ->
        jasmine.DEFAULT_TIMEOUT_INTERVAL = 10000
        ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5ake', options)
        ws.connect()
        message =
          kind: 'give-me-error'
          data:
            cmd: 'error'

        errorMessage = undefined
        success = (data) -> 'success'
        error = (reason) -> errorMessage = reason
        complete = (data) -> 'complete'
        
        promise = ws.send(message, {success, error, complete})

        promise.catch  (e) ->
          expect(new ReallyError(errorMessage)).toEqual e
          ws.disconnect()
          done()


    describe 'channel not connected', ->

      it 'should buffer messages if strategy chosen is "buffer"', ->
        ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5ake', options)
        #ws.connect()
        message = protocol.createMessage('/users')
        
        success = (data) -> 'success'
        error = (reason) -> 'error'
        complete = (data) -> 'complete'

        spyOn(ws._messagesBuffer, 'push').and.callThrough()
        promise = ws.send(message, {success, error, complete})
        expect(ws._messagesBuffer.push).toHaveBeenCalled()#With {message, options, promise}
        

      it 'should call custom message if strategy chosen is "custom"', (done) ->
        
        newOptions =
          onDisconnect: (that, messageBuffer, reallyError) ->
            expect(that).toEqual new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5ake', newOptions)
            expect(messageBuffer).toBe ws._messagesBuffer
            expect(reallyError).toEqual ReallyError
            done()
        ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5ake', newOptions)

        message = protocol.createMessage('/users')
        
        success = (data) -> 'success'
        error = (reason) -> 'error'
        complete = (data) -> 'complete'

        ws.send(message, {success, error, complete})

      it 'should fail messages if strategy chosen is "fail" by rejecting the promise', ->
        newOptions =
          onDisconnect: 'fail'
        ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5ake', newOptions)

        message = protocol.createMessage('/users')
        
        success = (data) -> 'success'
        error = (reason) -> 'error'
        complete = (data) -> 'complete'

        spyOn(ws._messagesBuffer, 'push').and.callThrough()
        promise = ws.send(message, {success, error, complete})
        promise.catch (e) ->
          expect(e).toEqual new ReallyError('Connection to the server is not established')

      it 'should return a promise when channel is not connected with any strategy', ->
        ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5ake', options)
        message = protocol.createMessage('/users')
        promise = ws.send(message, {})
        expect(typeof promise.then is 'function').toBeTruthy()


  describe 'reconnect', ->
    it 'should increase number of attempts with one', (done) ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5ake', options)
      ws.connect()
      ws.socket.addEventListener 'open', () ->
        ws.socket.close()
      ws.socket.addEventListener 'close', () ->
        expect(ws.attempts).toEqual 1
        ws.disconnect()
        done()

    it 'should reconnect when time out', (done) ->
      jasmine.clock().install()
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5ake', options)
      ws.connect()
      spyOn(ws, 'reconnect').and.callThrough()
      ws.socket.addEventListener 'open', () ->
        ws.socket.close()
      ws.socket.addEventListener 'close', () ->
        setTimeout( ->
          expect(ws.reconnect).toHaveBeenCalled()
          jasmine.clock().uninstall()
          ws.disconnect()
          done()
        , 30000)
        jasmine.clock().tick(30010)
      
  describe 'disconnect', ->

    it 'should close the websocket transport', (done) ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye', options)
      ws.connect()
      
      ws.socket.addEventListener 'open', () ->
        ws.disconnect()
        expect(ws).toBeNull
        ws.disconnect()
        done()


    it 'should set the initialized flag to false', (done) ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye', options)
      ws.connect()
      
      ws.socket.addEventListener 'open', () ->
        setTimeout(->
          expect(ws.initialized).toBeTruthy()
        , 1000)
        
        ws.disconnect()
        expect(ws.initialized).toBeFalsy()
        done()


    it 'should set the socket instance to null', (done) ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye', options)
      ws.connect()
      
      ws.socket.addEventListener 'open', () ->
        ws.disconnect()
        expect(ws.socket).toBeNull
        done()
  describe 'isConnecting', ->

    it 'should return false if socket is not initialized', ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye', options)
      ws.connect()
      
      setTimeout (->
        ws.socket = null
        expect(ws.isConnected()).toBeFalsy()
        ws.disconnect()
      ), 1000

    it 'should return true if socket is connecting',  ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye', options)
      ws.connect()
      expect(ws.isConnecting()).toBeTruthy()
      ws.disconnect()

  describe 'isConnected', ->

    it 'should return false if socket is not initialized', ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye', options)
      ws.connect()
      
      setTimeout (->
        ws.socket = null
        expect(ws.isConnected()).toBeFalsy()
        ws.disconnect()
      ), 1000


