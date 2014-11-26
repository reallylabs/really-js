protocol = require '../src/protocol.coffee'

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
              op: "addNumber"
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


    
  
