# Dependencies

Q            = require 'q'
ReallyObject = require '../src/really-object'
ReallyError  = require '../src/really-error'
protocol     = require '../src/protocol'

describe 'reallyObject', ->

  channel =
    send: -> true

  describe 'get', ->

    it 'should throw error if called without passing resource parameter', ->
      object = new ReallyObject()
      expect ->
        msg = object.get()
      .toThrow new ReallyError('Can not be initialized without resource')

    it 'should throw error if called with non-string resource parameter', ->
      object = new ReallyObject()
      expect ->
        msg    = object.get(123)
      .toThrow new ReallyError('Can not be initialized without resource')

    it 'should resolve promise when message sent successfully', (done) ->
      options =
        fields: ['author']

      spyOn(channel, 'send').and.callFake () ->
        deferred = Q.defer()
        deferred.resolve 'success'
        return deferred.promise

      object = new ReallyObject(channel)
      promise = object.get('/users/123', options)
      promise.done (data) ->
        expect(data).toEqual 'success'
        done()

    it 'should return rejected promise if the message fails', (done) ->
      options =
        fields: ['author']

      spyOn(channel, 'send').and.callFake () ->
        deferred = Q.defer()
        deferred.reject 'exception'
        return deferred.promise

      object = new ReallyObject(channel)
      promise = object.get('/users/123', options)
      promise.catch (data) ->
        expect(data).toEqual 'exception'
        done()

    it 'should return rejected promise if getMessage throws error', (done) ->
      options =
        fields: 123

      object = new ReallyObject(channel)
      promise = object.get('/users/123', options)
      errorCallBack = jasmine.createSpy('errorCallBack')
      promise.catch () -> errorCallBack()
      
      setTimeout ->
        expect(errorCallBack).toHaveBeenCalled()
        done()
      , 1

    it 'should call getMessage', ->
      options =
        fields: ['author']

      reallyObject = new ReallyObject(channel)
      spyOn(protocol, 'getMessage').and.callThrough()
      promise = reallyObject.get('/users/123', options)
      expect(protocol.getMessage).toHaveBeenCalledWith('/users/123', options.fields)

  describe 'update', ->

    it 'should throw error if initialized with non-string resource parameter', ->
      object = new ReallyObject()
      expect ->
        object.update(123)
      .toThrow new ReallyError('Can not be initialized without resource')

    it 'should throw error if called without options parameter', (done) ->
      object = new ReallyObject(channel)
      promise = object.update('/users/123', 12)

      promise.catch (data) ->
        expect(data.message).toEqual "Can\'t be called without passing arguments"
        done()

    it 'should resolve promise when message send successfully', (done) ->
      options =
        ops: [
          op: 'set'
          key: 'friends'
          value: 'Ahmed'
        ]

      spyOn(channel, 'send').and.callFake () ->
        deferred = Q.defer()
        deferred.resolve 'success'
        return deferred.promise

      object = new ReallyObject(channel)
      promise = object.update('/users/123', 3, options)
      promise.done (data) ->
        expect(data).toEqual 'success'
        done()

    it 'should reject promise when message unsent', (done) ->
      options =
        ops: [
          op: 'set'
          key: 'friends'
          value: 'Ahmed'
        ]

      spyOn(channel, 'send').and.callFake () ->
        deferred = Q.defer()
        deferred.reject 'exception'
        return deferred.promise

      object = new ReallyObject(channel)
      promise = object.update('/users/123', 3, options)
      promise.catch (data) ->
        expect(data).toEqual 'exception'
        done()

  describe 'delete', ->

    it 'should throw error if initialized with non-string resource parameter', ->
      object = new ReallyObject()
      expect ->
        object.update(123)
      .toThrow new ReallyError('Can not be initialized without resource')

    it 'should send a delete message', (done) ->
      options =
        onSuccess: (data) -> true
        onError: (error) -> true
        onComplete: (data) -> true

      spyOn(channel, 'send').and.callFake () ->
        deferred = Q.defer()
        deferred.resolve 'success'
        return deferred.promise

      object = new ReallyObject(channel)
      promise = object.delete('123', options)

      promise.done (data) ->
        expect(data).toEqual 'success'
        done()

  describe 'onUpdate', ->

    it 'should fire the onUpdate event', (done) ->
      message =
        cmd: 'push'
        r: 'users/123'
        evt: 'updated'
        rev: 12
        data:
          fields: ['name': 'really']

      object = new ReallyObject()
      spyOn(object, 'on').and.callThrough()

      object.onUpdate message.r, (data) ->
        expect(object.on).toHaveBeenCalledWith "#{message.r}:updated", jasmine.any Function
        done()

      object.emit "#{message.r}:#{message.evt}", message

  describe 'onDelete', ->

    it 'should fire the onDelete event', (done) ->
      message =
        cmd: 'push'
        r: 'users/123'
        evt: 'deleted'
        rev: 12
        data:
          fields: ['name': 'really']

      object = new ReallyObject()
      spyOn(object, 'on').and.callThrough()

      object.onDelete message.r, (data) ->
        expect(object.on).toHaveBeenCalledWith "#{message.r}:deleted", jasmine.any Function
        done()

      object.emit "#{message.r}:#{message.evt}", message
