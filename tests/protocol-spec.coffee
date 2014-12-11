#
# Dependencies.
#

protocol     = require '../src/protocol'
ReallyError  = require '../src/really-error'

describe 'protocol', ->

  describe 'initializationMessage', ->

    it 'should return a proper object when getting initialization message', ->
      message = protocol.initializationMessage('xxwmn93p0h')
      expect(message).toEqual
        type: 'initialization'
        data:
          cmd: 'init'
          accessToken: 'xxwmn93p0h'

  describe 'createMessage', ->

    it 'should throw error if called without passing body parameter as Object', ->
      expect ->
        message = protocol.createMessage('users/123', '123')
      .toThrow new ReallyError('You should pass a body parameter as Object')

    it 'should throw error when called without resource parameter', ->
      expect ->
        message = protocol.createMessage()
      .toThrow new ReallyError('You should pass a resource parameter as String')

    it 'should throw error when called with a non-string as a resource paramater', ->
      expect ->
        message = protocol.createMessage(123)
      .toThrow new ReallyError('You should pass a resource parameter as String')

    it 'should return a proper object when creating a message', ->
      message = protocol.createMessage('res')
      expect(message).toEqual
        type: 'create'
        data:
          cmd: 'create'
          r: 'res'

  describe 'getMessage', ->

    it 'should throw error if called without passing the fields parameter as an array or nothing', ->
      expect ->
        message = protocol.getMessage('/users/123', 'string')
      .toThrow new ReallyError('You should pass array or nothing for fields option')

    it 'should return proper format of message if correct parameters passed', ->
      message = protocol.getMessage('/users/123', ['name', 'email'])
      expect(message).toEqual
        type: 'get'
        data:
          cmd: 'get'
          r: '/users/123'
          cmdOpts:
            fields: ['name', 'email']

  describe 'updateMessage', ->

    it 'should throw error if called without passing an operation or it\'s length is zero', ->
      expect ->
        message = protocol.updateMessage('/users/1234/', 4, [])
      .toThrow new ReallyError('You should pass at least one operation')

      expect ->
        message = protocol.updateMessage('/users/1234/', 4)
      .toThrow new ReallyError('You should pass at least one operation')

    it 'should throw error if the passed operation is not supported', ->
      ops = [
        op: 'foo'
        key: 'friends'
        value: 'Ahmed'
      ]

      expect ->
        message = protocol.updateMessage('/users/1234/', 34, ops)
      .toThrow new ReallyError("\"#{ops[0].op}\" operation you passed is not supported")

    it 'should return proper format of message if correct parameters passed', ->
      ops = [
              op: 'set'
              key: 'friends'
              value: 'Ahmed'
            ,
              op: 'addNumber'
              key: 'age'
              value: 1
            ]

      message = protocol.updateMessage('/users/1234/', 34, ops)
      expect(message.data).toEqual
        cmd: 'update'
        r: '/users/1234/'
        rev: 34
        body:
          ops: [
              op: 'set'
              key: 'friends'
              value: 'Ahmed'
            ,
              op: 'addNumber'
              key: 'age'
              value: 1
          ]

  describe 'deleteMessage', ->

    it 'should throw error if called without passing a resource parameter', ->
      expect ->
        message = protocol.createMessage()
      .toThrow new ReallyError('You should pass a resource parameter as String')

    it 'should throw error if the passed resource parameter is not String', ->
      expect ->
        message = protocol.createMessage(123)
      .toThrow new ReallyError('You should pass a resource parameter as String')

    it 'should return proper format of message if correct parameters passed', ->
      message = protocol.deleteMessage('/users/1234/')
      expect(message.data).toEqual
        cmd: 'delete'
        r: '/users/1234/'

  describe 'readMessage', ->
    it 'should return proper format of message if correct parameters passed', ->
      options =
        fields: ['firstname', 'lastname', 'avatar']
        query:
          filter: 'name = $name and age > $age'
          values: 'name': 'Ahmed', 'age': 5
        limit: 10
        paginationToken: '23423423:1'
        skip: 1
        includeTotalCount: false
        subscribe: true

      message = protocol.readMessage('/users/*', options)

      expect(message).toEqual
        type: 'read'
        data:
          cmd: 'read'
          r: '/users/*'
          cmdOpts:
            fields: ['firstname', 'lastname', 'avatar']
            query:
              filter: 'name = $name and age > $age'
              values: {'name': 'Ahmed', 'age': 5}
            limit: 10
            paginationToken: '23423423:1'
            skip: 1
            includeTotalCount: false
            subscribe: true

    it 'should throw error if not supported option has been passed', ->
      options =
        notFields: ['firstname', 'lastname', 'avatar']
      expect ->
        message = protocol.readMessage('/users/*', options)
      .toThrow new ReallyError('The option "notFields" isn\'t supported')

    it 'should throw error if wrong type of option has been passed', ->
      options =
        fields: 'avatar'
      expect ->
        message = protocol.readMessage('/users/*', options)
      .toThrow new ReallyError('You should pass Array  for "fields" option')

  describe 'heartbeatMessage', ->

    it 'should return proper format of message if heartbeatMessage is called', ->
      message = protocol.heartbeatMessage()
      time = Date.now()
      expect(message).toEqual
        type: 'poke'
        data:
          cmd: 'poke'
          timestamp: time

  describe 'isErrorMessage', ->

    it 'should return true if the message object has a property called error', ->
      messageEmpty        = { }
      messageWithoutError = { sucess: true }
      messageWithError    = { error: true }

      expect(protocol.isErrorMessage(messageEmpty)).toBeFalsy()
      expect(protocol.isErrorMessage(messageWithoutError)).toBeFalsy()
      expect(protocol.isErrorMessage(messageWithError)).toBeTruthy()
