protocol = require '../src/protocol.coffee'
ReallyError = require '../src/really-error.coffee'

describe 'protocol', ->
  describe 'getMessage', ->
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
      
