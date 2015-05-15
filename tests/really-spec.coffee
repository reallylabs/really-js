#
# Module dependencies.
#
Really = require '../src/really'
CONFIG = require './support/server/config'
ReallyError = require '../src/really-error'
PushHandler = require '../src/push-handler'

describe 'Really', ->

  describe 'initialization', ->

    it 'should raise really error if no domain and access token passed to it', ->
      expect ->
        really = new Really()
      .toThrow new ReallyError('Can\'t initialize Really without passing domain and access token')

    it 'should raise really error if domain is not string', ->
      expect ->
        really = new Really(123, 'ibj88w5aye')
      .toThrow new ReallyError('Only <String> values are allowed for domain and access token')

    it 'should raise really error if access token is not string', ->
      expect ->
        really = new Really(CONFIG.REALLY_DOMAIN, 123)
      .toThrow new ReallyError('Only <String> values are allowed for domain and access token')

    it 'should listen to message coming from server and handle the messages without tags', ->
      really = new Really(CONFIG.REALLY_DOMAIN, 'ibj88w5aye', {reconnect: false})
      spyOn(PushHandler, 'handle')
      really.transport.emit 'message', 'data'
      expect(PushHandler.handle).toHaveBeenCalledWith(really, 'data')
      really.transport.disconnect()

    describe 'two instances with the same domain', ->
      it 'should use the same object', ->
        really1 = new Really(CONFIG.REALLY_DOMAIN, 'ibj88w5aye', {reconnect: false})
        really2 = new Really(CONFIG.REALLY_DOMAIN, 'ibj88w5aye', {reconnect: false})
        expect(really1.object).toBe really2.object
        really1.transport.disconnect()

      it 'should use the same collection', ->
        really1 = new Really(CONFIG.REALLY_DOMAIN, 'ibj88w5aye', {reconnect: false})
        really2 = new Really(CONFIG.REALLY_DOMAIN, 'ibj88w5aye', {reconnect: false})
        expect(really1.collection).toBe really2.collection
        really2.transport.disconnect()

      it 'should use the same transport instance', ->
        really1 = new Really(CONFIG.REALLY_DOMAIN, 'ibj88w5aye', {reconnect: false})
        really2 = new Really(CONFIG.REALLY_DOMAIN, 'ibj88w5aye', {reconnect: false})
        expect(really1.transport).toBe really2.transport
        really1.transport.disconnect()

    describe 'two instances with different domains', ->
      
      it 'should use new object', ->
        really1 = new Really('ws://localhost:1337', 'ibj88w5aye', {reconnect: false})
        really2 = new Really('ws://localhost:1338', 'ibj88w5aye', {reconnect: false})
        expect(really1.object).not.toBe really2.object
        really1.transport.disconnect()
        really2.transport.disconnect()

      it 'should use new collection', ->
        really1 = new Really('ws://localhost:1337', 'ibj88w5aye', {reconnect: false})
        really2 = new Really('ws://localhost:1338', 'ibj88w5aye', {reconnect: false})
        expect(really1.object).not.toBe really2.object
        really1.transport.disconnect()
        really2.transport.disconnect()

      it 'should initialize new transport instance', ->
        really1 = new Really('ws://localhost:1337', 'ibj88w5aye', {reconnect: false})
        really2 = new Really('ws://localhost:1338', 'ibj88w5aye', {reconnect: false})
        expect(really1.transport).not.toBe really2.transport
        really1.transport.disconnect()
        really2.transport.disconnect()
    
