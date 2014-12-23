#
# Module dependencies.
#
protocol        = require '../src/protocol'
CallbacksBuffer = require '../src/callbacks-buffer'
ReallyError     = require '../src/really-error'
_               = require 'lodash'

describe 'CallbacksBuffer', ->

  describe 'initialization', ->

    it 'should start with tag equal 0', ->
      buffer1 = new CallbacksBuffer()
      expect(buffer1.tag).toEqual 0
      buffer1.add()
      buffer1.add()
      buffer2 = new CallbacksBuffer()
      expect(buffer2.tag).toEqual 0

    it 'should start with empty object for callbacks', ->
      buffer1 = new CallbacksBuffer()
      expect(buffer1._callbacks).toEqual {}
      buffer1.add()
      buffer1.add()
      buffer1.add()
      expect(_.keys(buffer1._callbacks).length).toEqual 3
      buffer2 = new CallbacksBuffer()
      expect(buffer2._callbacks).toEqual {}

  describe 'handle', ->
    it 'should raise exception if a message without tag is passed', ->
      buffer = new CallbacksBuffer()
      messageWithoutTag = {error: true}
      expect ->
        buffer.handle(messageWithoutTag)
      .toThrow new ReallyError('A message with this tag: undefined doesn\'t exist')

    it 'should throw error if the complete callback raised exception', ->
      buffer = new CallbacksBuffer()
      message =
        tag: 5
      complete = (data) ->
        throw new Error('error')

      success = (data) -> 'success'

      buffer._callbacks[5] = {kind: 'default', success, complete}


      expect ->
        buffer.handle(message)
      .toThrow new ReallyError('Error happened when trying to execute your complete callback')

    it 'should throw error if the success callback raised exception', ->
      buffer = new CallbacksBuffer()
      message =
        tag: 5
        evt: 'updated'
        body:
          f: 'name'
          value: 'Ihab'

      complete = (data) -> 'complete'
      success = (data) -> throw new Error('error')

      buffer._callbacks[5] = {kind: 'default', success, complete}

      expect ->
        buffer.handle(message)
      .toThrow new ReallyError('Error happened when trying to execute your success callback')

    it 'should throw error if the error callback raised exception', ->
      buffer = new CallbacksBuffer()
      message =
        tag: 5
        error: true

      complete = (data) -> 'complete'
      error = (data) -> throw new Error('error')

      buffer._callbacks[5] = {kind: 'default', error, complete}

      expect ->
        buffer.handle(message)
      .toThrow new ReallyError('Error happened when trying to execute your error callback')


    it 'should invoke the error callback if the message is error message', ->
      buffer = new CallbacksBuffer()
      errorMessage =
        tag: 5
        error: true

      options =
        error: (reason) ->  'error'
        success: (data) -> 'success'
        complete: (data) -> 'complete'

      spyOn(options, 'error')
      spyOn(options, 'complete')
      spyOn(options, 'success')
      buffer._callbacks[5] = {kind: 'default', error: options.error, complete: options.complete}

      buffer.handle(errorMessage)
      expect(options.error).toHaveBeenCalled()
      expect(options.complete).toHaveBeenCalled()
      expect(options.success).not.toHaveBeenCalled()


    it 'should invoke the success callback if the message is success message', ->
      buffer = new CallbacksBuffer()
      message  =
        tag: 5
        evt: 'created'
        body:
          name: 'Ihab'
          _res: '/users/12'

      options =
        success: (data) -> 'success'
        error: (reason) -> 'Error'
        complete: (data) -> 'complete'

      spyOn(options, 'success')
      spyOn(options, 'error')
      spyOn(options, 'complete')
      buffer._callbacks[5] = {kind: 'default', success: options.success, complete: options.complete}

      buffer.handle(message)
      expect(options.success).toHaveBeenCalled()
      expect(options.complete).toHaveBeenCalled()
      expect(options.error).not.toHaveBeenCalled()

    it 'should invoke the complete callback', ->
      buffer = new CallbacksBuffer()
      message =
        tag: 5
        success: true

      options =
        error: (reason) -> 'error'
        success: (data) -> 'success'
        complete: (data) -> 'complete'

      spyOn(options, 'complete')
      spyOn(options, 'success')
      spyOn(options, 'error')
      buffer._callbacks[5] = {kind: 'default', success: options.success, complete: options.complete}

      buffer.handle(message)
      expect(options.complete).toHaveBeenCalled()
      expect(options.success).toHaveBeenCalled()
      expect(options.error).not.toHaveBeenCalled()


    it 'should delete the tag after invoking its callbacks', ->
      buffer = new CallbacksBuffer()
      message =
        tag: 5

      success = (data) -> 'success'

      complete = (data) -> 'complete'

      buffer._callbacks[5] = {kind: 'default', success, complete}

      buffer.handle(message)

      expect(buffer._callbacks[5]).toBeUndefined()

    it 'should throw ReallyError when tag does not exist', ->
      buffer = new CallbacksBuffer()
      message =
        tag: 5
        cmd: 'fill'
        body:
          name: 'Ihab'

      expect ->
        buffer.handle(message)
      .toThrow new ReallyError('A message with this tag: 5 doesn\'t exist')

  describe 'add', ->

    it 'should return new tag when passing empty arguments', ->
      buffer = new CallbacksBuffer()
      expect(buffer.tag).toEqual 0
      tag = buffer.add()
      expect(tag).toEqual 1
      tag = buffer.add {}
      tag = buffer.add {}
      tag = buffer.add {}
      expect(tag).toEqual 4

    it 'should return new tag when passing arguments', ->
      buffer = new CallbacksBuffer()
      expect(buffer.tag).toEqual 0
      kind = 'add'

      success = (data) -> data
      error = (reason) -> reason
      complete = (data) -> data
      tag = buffer.add {kind, success, error, complete}
      
      expect(tag).toEqual 1
      
      tag = buffer.add {kind, success, error, complete}
      tag = buffer.add {kind, success, error, complete}
      tag = buffer.add {kind, success, error, complete}
      tag = buffer.add {kind, success, error, complete}
      
      expect(tag).toEqual 5

    it 'should add callbacks to buffer with appropriate tags', ->
      buffer = new CallbacksBuffer()
      expect(buffer._callbacks).toEqual {}
      
      success = () -> 'success'
      error = () -> 'error'
      complete = () -> 'complete'

      data1 = {success, error, complete}
      data2 = {success, error, complete}
      data3 = {success, error, complete}
      data1.kind = '1'
      data2.kind = '2'
      data3.kind = '3'

      buffer.add data1
      expect(buffer._callbacks).toEqual {1: data1}
      
      buffer.add data2
      expect(_.keys(buffer._callbacks).length).toEqual 2
      expect(buffer._callbacks[1]['kind']).toEqual '1'
      expect(buffer._callbacks[2]['kind']).toEqual '2'

      buffer.add data3
      expect(_.keys(buffer._callbacks).length).toEqual 3
      expect(buffer._callbacks[1]['kind']).toEqual '1'
      expect(buffer._callbacks[2]['kind']).toEqual '2'
      expect(buffer._callbacks[3]['kind']).toEqual '3'

      buffer.add({kind: 'test'})
      expect(_.keys(buffer._callbacks).length).toEqual 4
      expect(buffer._callbacks[1]['kind']).toEqual '1'
      expect(buffer._callbacks[2]['kind']).toEqual '2'
      expect(buffer._callbacks[3]['kind']).toEqual '3'
      expect(buffer._callbacks[4]['kind']).toEqual 'test'
    
    it 'should put appropriate default values if not supplied', ->
      buffer = new CallbacksBuffer()
      success = () -> 'success'
      error = () -> 'error'
      complete = () -> 'complete'
      kind = 'kind'

      defaultValues =
        kind: 'default'
        success: _.noop
        error: _.noop
        complete: _.noop

      data1 = {}
      data2 = {kind: 'kind2', success, error, complete}
      data3 = {kind: 'kind3', success, error}
      data4 = {kind: 'kind4', success}
      data5 = {kind: 'kind5'}

      buffer.add data1
      expect(buffer._callbacks[1]).toEqual defaultValues

      buffer.add data2
      expect(buffer._callbacks[2]).toEqual data2

      buffer.add data3
      expect(buffer._callbacks[3]['kind']).toEqual data3.kind
      expect(buffer._callbacks[3]['success']()).toEqual 'success'
      expect(buffer._callbacks[3]['error']()).toEqual 'error'
      expect(buffer._callbacks[3]['complete']).toEqual defaultValues.complete

      buffer.add data4
      expect(buffer._callbacks[4]['kind']).toEqual data4.kind
      expect(buffer._callbacks[4]['success']()).toEqual 'success'
      expect(buffer._callbacks[4]['error']).toEqual defaultValues.error
      expect(buffer._callbacks[4]['complete']).toEqual defaultValues.complete

      buffer.add data5
      expect(buffer._callbacks[5]['kind']).toEqual data5.kind
      expect(buffer._callbacks[5]['success']).toEqual defaultValues.success
      expect(buffer._callbacks[5]['error']).toEqual defaultValues.error
      expect(buffer._callbacks[5]['complete']).toEqual defaultValues.complete
