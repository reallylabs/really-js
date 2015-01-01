# Dependencies

protocol    = require '../src/protocol'
ReallyError = require '../src/really-error'

describe 'protocol', ->

  describe 'initializationMessage', ->

    it 'should throw error if message initialized without passing accessToken', ->
      expect ->
        message = protocol.initializationMessage()
      .toThrow new ReallyError('You should pass accessToken parameter as String')

    it 'should throw error when message initialized with a non-string as an accessToken paramater', ->
      expect ->
        message = protocol.initializationMessage(1234)
      .toThrow new ReallyError('You should pass accessToken parameter as String')

    it 'should return a proper object when getting initialization message', ->
      message = protocol.initializationMessage('xxwmn93p0h')
      expect(message).toEqual
        kind: 'initialization'
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

    it 'should throw error when called with a non-string as a resource parameter', ->
      expect ->
        message = protocol.createMessage(123)
      .toThrow new ReallyError('You should pass a resource parameter as String')

    it 'should return a proper object when creating a message', ->
      message = protocol.createMessage('res')
      expect(message).toEqual
        kind: 'create'
        data:
          cmd: 'create'
          r: 'res'

  describe 'readMessage', ->

    it 'should throw error if passed option is not supported', ->
      options =
        foo: ['firstname', 'lastname', 'avatar']

      expect ->
        message = protocol.readMessage('/users/*', options)
      .toThrow new ReallyError("The option \"foo\" isn't supported")

    it 'should throw error if the fields option is not an Array', ->
      options =
        fields: 'string'

      expect ->
        message = protocol.readMessage('/users/*', options)
      .toThrow new ReallyError('You should pass Array for \"fields\" option')

    it 'should throw error if the query option is not an Object', ->
      options =
        query:
          filter: 123
          values: 'string'

      expect ->
        message = protocol.readMessage('/users/*', options)
      .toThrow new ReallyError('You should pass Object for \"query\" option')

    it 'should return proper format of message if the query option passed with the right format', ->
      options =
        query:
          filter: 'name = $name and age > $age'
          values:
            'name': 'Ahmed'
            'age': 5

      message = protocol.readMessage('/users/*', options)

      expect(message).toEqual
        kind: 'read'
        data:
          cmd: 'read'
          r: '/users/*'
          cmdOpts:
            query:
              filter: 'name = $name and age > $age'
              values:
                'name': 'Ahmed'
                'age': 5

    it 'should throw error if the limit option is not a Number', ->
      options =
        limit: 'string'

      expect ->
        message = protocol.readMessage('/users/*', options)
      .toThrow new ReallyError('You should pass Number for \"limit\" option')

    it 'should throw error if the skip option is not a Number', ->
      options =
        skip: 'string'

      expect ->
        message = protocol.readMessage('/users/*', options)
      .toThrow new ReallyError('You should pass Number for \"skip\" option')

    it 'should throw error if the sort option is not a String', ->
      options =
        sort: 123

      expect ->
        message = protocol.readMessage('/users/*', options)
      .toThrow new ReallyError('You should pass String for \"sort\" option')

    it 'should throw error if the token option is not a String', ->
      options =
        token: 123

      expect ->
        message = protocol.readMessage('/users/*', options)
      .toThrow new ReallyError('You should pass String for \"token\" option')

    it 'should throw error if the includeTotalCount option is not a String', ->
      options =
        includeTotalCount: 123

      expect ->
        message = protocol.readMessage('/users/*', options)
      .toThrow new ReallyError('You should pass Boolean for \"includeTotalCount\" option')

    it 'should throw error if the paginationToken option is not a String', ->
      options =
        paginationToken: 123

      expect ->
        message = protocol.readMessage('/users/*', options)
      .toThrow new ReallyError('You should pass String for \"paginationToken\" option')

    it 'should throw error if the subscribe option is not a Boolean', ->
      options =
        subscribe: 123

      expect ->
        message = protocol.readMessage('/users/*', options)
      .toThrow new ReallyError('You should pass Boolean for \"subscribe\" option')

    it 'should return proper format of message if correct parameters passed', ->
      options =
        fields: ['firstname', 'lastname', 'avatar']
        query:
          filter: 'name = $name and age > $age'
          values:
            'name': 'Ahmed'
            'age': 5
        limit: 10
        paginationToken: '23423423:1'
        skip: 1
        includeTotalCount: false
        subscribe: true

      message = protocol.readMessage('/users/*', options)

      expect(message).toEqual
        kind: 'read'
        data:
          cmd: 'read'
          r: '/users/*'
          cmdOpts:
            fields: ['firstname', 'lastname', 'avatar']
            query:
              filter: 'name = $name and age > $age'
              values:
                'name': 'Ahmed'
                'age': 5
            limit: 10
            paginationToken: '23423423:1'
            skip: 1
            includeTotalCount: false
            subscribe: true

  describe 'getMessage', ->

    it 'should throw error if called without passing the fields parameter as an array or nothing', ->
      expect ->
        message = protocol.getMessage('/users/123', 'string')
      .toThrow new ReallyError('You should pass array or nothing for fields option')

    it 'should return proper format of message if correct parameters passed', ->
      message = protocol.getMessage('/users/123', ['name', 'email'])
      expect(message).toEqual
        kind: 'get'
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
        message = protocol.deleteMessage()
      .toThrow new ReallyError('You should pass a resource parameter as String')

    it 'should throw error if the passed resource parameter is not String', ->
      expect ->
        message = protocol.deleteMessage(123)
      .toThrow new ReallyError('You should pass a resource parameter as String')

    it 'should return proper format of message if correct parameters passed', ->
      message = protocol.deleteMessage('/users/1234/')
      expect(message.data).toEqual
        cmd: 'delete'
        r: '/users/1234/'

  describe 'subscribeMessage', ->

    it 'should throw error if called with none subscriptions parameter or is not Object or Array of Objects', ->
      expect ->
        message = protocol.subscribeMessage()
      .toThrow new ReallyError('subscription(s) should be either Object or Array of Objects')

      expect ->
        message = protocol.subscribeMessage('string')
      .toThrow new ReallyError('subscription(s) should be either Object or Array of Objects')

    it 'should throw error if called with non-string resource and non-number revision for subscription object', ->
      subscriptions =
        res: 123
        rev: 123

      expect ->
        message = protocol.subscribeMessage(subscriptions)
      .toThrow new ReallyError('You must pass string resource and number revision for subscription object')

    it 'should throw error if called with non-string resource and non-number revision for subscription object', ->
      subscriptions =
        res: 123
        rev: '123'

      expect ->
        message = protocol.subscribeMessage(subscriptions)
      .toThrow new ReallyError('You must pass string resource and number revision for subscription object')

    it 'should throw error if called with non-string resource and non-number revision for subscription object', ->
      subscriptions =
        res: '123'
        rev: '123'

      expect ->
        message = protocol.subscribeMessage(subscriptions)
      .toThrow new ReallyError('You must pass string resource and number revision for subscription object')

    it 'should return proper format of message if subscribeMessage is called with Array of Objects', ->
      subscriptions = [
        res: '/users/123'
        rev: 12
      ,
        res: '/users/456'
        rev: 34
      ]

      message = protocol.subscribeMessage(subscriptions)

      expect(message).toEqual
        kind: 'subscribe'
        data:
          cmd: 'subscribe'
          subscriptions: subscriptions

    it 'should return proper format of message if subscribeMessage is called', ->
      subscriptions =
        res: '/users/123'
        rev: 12

      message = protocol.subscribeMessage(subscriptions)

      expect(message).toEqual
        kind: 'subscribe'
        data:
          cmd: 'subscribe'
          subscriptions: [subscriptions]

    it 'should wrap the subscriptions object in Array when passed to subscribeMessage', ->
      subscriptions =
        res: '/users/123'
        rev: 12

      message = protocol.subscribeMessage(subscriptions)

      expect(message).toEqual
        kind: 'subscribe'
        data:
          cmd: 'subscribe'
          subscriptions: [subscriptions]

  describe 'unsubscribeMessage', ->
    it 'should throw error if called with none subscriptions parameter or is not Object or Array of Objects', ->
      expect ->
        message = protocol.unsubscribeMessage()
      .toThrow new ReallyError('subscription(s) should be either Object or Array of Objects')

      expect ->
        message = protocol.unsubscribeMessage('string')
      .toThrow new ReallyError('subscription(s) should be either Object or Array of Objects')

    it 'should throw error if called with non-string resource and non-number revision for subscription object', ->
      subscriptions =
        res: 123
        rev: 123

      expect ->
        message = protocol.unsubscribeMessage(subscriptions)
      .toThrow new ReallyError('You must pass string resource and number revision for subscription object')

    it 'should throw error if called with non-string resource and non-number revision for subscription object', ->
      subscriptions =
        res: 123
        rev: '123'

      expect ->
        message = protocol.unsubscribeMessage(subscriptions)
      .toThrow new ReallyError('You must pass string resource and number revision for subscription object')

    it 'should throw error if called with non-string resource and non-number revision for subscription object', ->
      subscriptions =
        res: '123'
        rev: '123'

      expect ->
        message = protocol.unsubscribeMessage(subscriptions)
      .toThrow new ReallyError('You must pass string resource and number revision for subscription object')

    it 'should return proper format of message if unsubscribeMessage is called with Array of Objects', ->
      subscriptions = [
        res: '/users/123'
        rev: 12
      ,
        res: '/users/456'
        rev: 34
      ]

      message = protocol.unsubscribeMessage(subscriptions)

      expect(message).toEqual
        kind: 'unsubscribe'
        data:
          cmd: 'unsubscribe'
          subscriptions: subscriptions

    it 'should return proper format of message if unsubscribeMessage is called with Object', ->
      subscriptions =
        res: '/users/123'
        rev: 12

      message = protocol.unsubscribeMessage(subscriptions)

      expect(message).toEqual
        kind: 'unsubscribe'
        data:
          cmd: 'unsubscribe'
          subscriptions: [subscriptions]

    it 'should wrap the subscriptions object in Array when passed to unsubscribeMessage', ->
      subscriptions =
        res: '/users/123'
        rev: 12

      message = protocol.unsubscribeMessage(subscriptions)

      expect(message).toEqual
        kind: 'unsubscribe'
        data:
          cmd: 'unsubscribe'
          subscriptions: [subscriptions]

  describe 'heartbeatMessage', ->

    it 'should return proper format of message if heartbeatMessage is called', ->
      time = spyOn(Date, 'now').and.returnValue(1404810612883)

      message = protocol.heartbeatMessage()

      expect(message).toEqual
        kind: 'poke'
        data:
          cmd: 'poke'
          timestamp: time()

  describe 'isErrorMessage', ->

    it 'should return true if the message object has a property called error', ->
      successMessage = { }
      errorMessage   = { error: true }

      expect(protocol.isErrorMessage(successMessage)).toBeFalsy()
      expect(protocol.isErrorMessage(errorMessage)).toBeTruthy()
