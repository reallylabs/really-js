# Dependencies

Q                = require 'q'
ReallyCollection = require '../src/really-collection'
ReallyError      = require '../src/really-error'
protocol         = require '../src/protocol'

describe 'reallyCollection', ->

  channel =
    send: -> true

  describe 'create', ->

    it 'should throw error if called without passing res parameter', ->
      collection = new ReallyCollection()
      expect ->
        collection.create()
      .toThrow new ReallyError('Can not be initialized without resource')

    it 'should throw error if called with non-string res parameter', ->
      collection = new ReallyCollection()
      expect ->
        collection.create(123)
      .toThrow new ReallyError('Can not be initialized without resource')

    it 'should resolve promise when message send successfully', (done) ->
      options =
        fields: ['author']

      spyOn(channel, 'send').and.callFake () ->
        deferred = Q.defer()
        deferred.resolve 'success'
        return deferred.promise

      collection = new ReallyCollection(channel)
      promise = collection.create('/users/123', options)
      promise.done (data) ->
        expect(data).toEqual 'success'
        done()

    it 'should reject promise when sending message fails', (done) ->
      options =
        fields: ['author']

      spyOn(channel, 'send').and.callFake( () ->
        deferred = Q.defer()
        deferred.reject 'exception'
        return deferred.promise
      )

      collection = new ReallyCollection(channel)
      promise = collection.create('/users/123', options)
      promise.catch (data) ->
        expect(data).toEqual 'exception'
        done()

    it 'should return rejected promise if createMessage throws error', (done) ->
      options =
        fields: 12

      spyOn(channel, 'send').and.callFake () ->
        deferred = Q.defer()
        deferred.reject 'exception'
        return deferred.promise

      collection = new ReallyCollection(channel)
      promise = collection.create('/users/123', options)
      
      errorCallBack = jasmine.createSpy('errorCallBack')
      promise.catch () -> errorCallBack()
      
      setTimeout ->
        expect(errorCallBack).toHaveBeenCalled()
        done()
      , 1


    it 'should call createMessage',  ->

      options =
        body: ['author']

      collection = new ReallyCollection(channel)
      spyOn(protocol, 'createMessage').and.callThrough()
      promise = collection.create('/users/123', options)
      expect(protocol.createMessage).toHaveBeenCalledWith('/users/123', options.body)

  describe 'read', ->
    it 'should throw error if called without passing res parameter', ->
      collection = new ReallyCollection()
      expect ->
        collection.read()
      .toThrow new ReallyError('Can not be initialized without resource')

    it 'should throw error if called with non-string res parameter', ->
      collection = new ReallyCollection()
      expect ->
        collection.read(123)
      .toThrow new ReallyError('Can not be initialized without resource')

    it 'should resolve promise when message send successfully', (done) ->
      options =
        fields: ['author']

      spyOn(channel, 'send').and.callFake () ->
        deferred = Q.defer()
        deferred.resolve 'success'
        return deferred.promise

      collection = new ReallyCollection(channel)
      promise = collection.read('/users/123', options)
      promise.done (data) ->
        expect(data).toEqual 'success'
        done()

    it 'should reject promise when the message fails', (done) ->
      options =
        fields: ['author']

      spyOn(channel, 'send').and.callFake () ->
        deferred = Q.defer()
        deferred.reject 'exception'
        return deferred.promise

      collection = new ReallyCollection(channel)
      promise = collection.read('/users/123', options)
      promise.catch (data) ->
        expect(data).toEqual 'exception'
        done()

    it 'should reject if createMessage throws error', (done) ->
      options =
        fields: 12

      spyOn(channel, 'send').and.callFake () ->
        deferred = Q.defer()
        deferred.reject 'exception'
        return deferred.promise

      collection = new ReallyCollection(channel)
      promise = collection.read('/users/123', options)
      errorCallBack = jasmine.createSpy('errorCallBack')
      promise.catch () -> errorCallBack()
      
      setTimeout ->
        expect(errorCallBack).toHaveBeenCalled()
        done()
      , 1
     

    it 'should call readMessage', ->

      options =
        body: ['author']

      collection = new ReallyCollection(channel)
      spyOn(protocol, 'readMessage').and.callThrough()
      promise = collection.read('/users/123', options)
      expect(protocol.readMessage).toHaveBeenCalledWith('/users/123', options)

  describe 'onCreate', ->

    it 'should fire the onCreate event', (done) ->
      message =
        r: '/users/'
        evt: 'created'
        rev: 0
        data:
          r: '/users/123'
          name: 'really'

      collection = new ReallyCollection()
      spyOn(collection, 'on').and.callThrough()
      collection.onCreate message.r, (data) ->
        expect(collection.on).toHaveBeenCalledWith "#{message.r}:created", jasmine.any Function
        done()

      collection.emit "#{message.r}:#{message.evt}", message
