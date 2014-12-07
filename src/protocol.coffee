###*
 * Protocol
 * This module is responsible for generating protocol messages
###
_ = require 'lodash'
authenticator = require './authenticator.coffee'
ReallyError = require './really-error.coffee'

VERSION = '0'
module.exports =

  clientVersion: VERSION

  commands:
    'init': 'init'
    'create': 'create'
    'read': 'read'
    'get': 'get'
    'update': 'update'
    'delete': 'delete'
    'heartbeat': 'poke'
    'subscribe': 'subscribe'
    'unsubscribe': 'unsubscribe'

  initializationMessage: (accessToken) ->
    'type': 'initialization'
    'data':
      'cmd': @commands.init
      'accessToken': accessToken

  createMessage: (res, body) ->
    
    throw new ReallyError('You should pass a resource parameter as String')  unless _.isString res
    
    unless _.isObject(body) or _.isUndefined(body)
      throw new ReallyError('You should pass a body parameter as Object')
    
    message =
      type: 'create'
      data:
        cmd: @commands.create
        r: res
    
    message['body'] = body if body

    return message

  readMessage: (res, options) ->
    cmdOpts = _.omit options, (value) -> value is undefined

    supportedOptions =
      fields:
        valid: _.isArray
        message: 'You should pass Array  for "fields" option'
      query:
        valid: (query) ->
          _.isObject(query) and ( _.isString(query.fields) or _.isObject(query.values) )
        message: 'You should pass Object  for "query" option'
      limit:
        valid: _.isNumber
        message: 'You should pass Number  for "limit" option'
      skip:
        valid: _.isNumber
        message: 'You should pass Number  for "skip" option'
      sort:
        valid: _.isString
        message: 'You should pass String  for "sort" option'
      token:
        valid: _.isString
        message: 'You should pass String  for "token" option'
      includeTotalCount:
        valid: _.isBoolean
        message: 'You should pass Boolean  for "includeTotalCount" option'
      paginationToken:
        valid: _.isString
        message: 'You should pass String  for "fields" option'
      subscribe:
        valid: _.isBoolean
        message: 'You should pass Boolean  for "subscribe" option'

    for option, value of cmdOpts
      if option not of supportedOptions
        throw new ReallyError("The option \"#{option}\" isn't supported")

      currnetOption = supportedOptions[option]
      if not currnetOption.valid(value)
        throw new ReallyError(currnetOption.message)

    # compose the message
    message =
      type: 'read'
      data:
        cmd: @commands.read
        r: res

    message.data.cmdOpts = cmdOpts if cmdOpts

    return message

  getMessage: (res, fields) ->
    if not (_.isArray fields or not fields)
      throw new ReallyError('You should pass array or nothing for fields option')

    message =
      type: 'get'
      data:
        cmd: @commands.get
        r: res

    if fields
      message.data.cmdOpts = fields: fields
    return message

  updateMessage: (res, rev, ops) ->
    if not ops or ops.length is 0
      throw new ReallyError('You should pass at least one operation')

    supportedOperations = ['set', 'addNumber', 'push', 'addToSet', 'insertAt', 'pull', 'removeAt']
    for operation in ops
      if operation.op not in supportedOperations
        throw new ReallyError("\"#{operation.op}\" operation you passed is not supported")

    message =
      type: 'update'
      data:
        cmd: @commands.update
        rev: rev
        r: res
        body: {ops}

    return message

  deleteMessage: (res) ->
    throw new ReallyError('You should pass a resource parameter as String') unless _.isString res
    
    type: 'delete'
    data:
      cmd: @commands.delete
      r: res

  subscribeMessage: (subscriptions) ->
    unless subscriptions or  _.isArray(subscriptions)  or  _.isObject(subscriptions)
      throw new ReallyError('subscription(s) should be either Object or Array of Objects')

    subscriptions = [subscriptions] if not _.isArray subscriptions
    for subscription in subscriptions
      if not ( _.isString(subscription.rev) and _.isString(subscriptions.res) )
        throw new ReallyError('You must pass valid resource and revision for subscription object')
    
    message =
      type: 'subscribe'
      data:
        cmd: @commands.subscribe
        subscriptions: subscriptions

  unsubscribeMessage: (subscriptions) ->
    if not subscriptions or not _.isArray(subscriptions) or not _.isObject(subscriptions)
      throw new ReallyError('subscription(s) should be either Object or Array of Objects')

    subscriptions = [subscriptions] if not _.isArray subscriptions
    
    for subscription in subscriptions
      if not ( _.isString(subscription.rev) and _.isString(subscriptions.res) )
        throw new ReallyError('You must pass valid resource and revision for subscription object')
    
    message =
      type: 'unsubscribe'
      data:
        cmd: @commands.unsubscribe
        subscriptions: subscriptions

  heartbeatMessage: () ->
    time = Date.now()

    type: 'poke'
    data:
      cmd: @commands.heartbeat
      timestamp: time

  isErrorMessage: (message) -> _.has message, 'error'
