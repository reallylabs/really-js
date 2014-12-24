#
# Module dependencies.
#
pushHandler = require '../src/push-handler'
ReallyError = require '../src/really-error'

describe 'pushHandler', ->
  describe 'handle', ->
    really = {}
    beforeEach ->
      really =
        emit: -> true
        object:
          emit: -> true
        collection:
          emit: -> true

      spyOn really, 'emit'
      spyOn really.object, 'emit'
      spyOn really.collection, 'emit'

    it 'should fire "updated" event on "object" when message with "updated" event received', ->
      message =
        evt: 'updated'
        r: '/users/*'
        body:
          ops: [
            val: 'Ihab'
            f: 'name'
            op: 'set'
          ]

      pushHandler.handle really, message
      expect(really.object.emit).toHaveBeenCalledWith "#{message.r}:#{message.evt}", message
  
    it 'should fire "deleted" event on "object" when message with "deleted" event received', ->
      message =
        evt: 'deleted'
        r: '/users/123'

      pushHandler.handle really, message
      expect(really.object.emit).toHaveBeenCalledWith "#{message.r}:#{message.evt}", message
    
    it 'should fire "created" event on "collection" when message with "created" event received', ->
      message =
        evt: 'created'
        r: '/users/*'
        body:
          name: 'ihab'
          age: 23

      pushHandler.handle really, message
      expect(really.collection.emit).toHaveBeenCalledWith "#{message.r}:#{message.evt}", message

    it 'should fire "kicked" event on "really" when message with "kicked" event received', ->
      message =
        evt: 'kicked'
      pushHandler.handle really, message
      expect(really.emit).toHaveBeenCalledWith "#{message.evt}", message

    it 'should fire "revoked" event on "really" when message with "revoked" event received', ->
      message =
        evt: 'revoked'
      pushHandler.handle really, message
      expect(really.emit).toHaveBeenCalledWith "#{message.evt}", message
 
    it 'should throw error if message with unsupported event received', ->
      message =
        evt: 'HelloWorld!'
      expect ->
        pushHandler.handle really, message
      .toThrow new ReallyError('Unknown event: HelloWorld!')
