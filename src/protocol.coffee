# Protocol
# This module is responsible for generating protocol messages

_              = require 'lodash'
authenticator  = require './authenticator'
ReallyError    = require './really-error'

VERSION        = '0.1'
module.exports =

  clientVersion: VERSION

  commands:
    init: 'initialize'
    create: 'create'
    read: 'read'
    get: 'get'
    update: 'update'
    delete: 'delete'
    heartbeat: 'poke'
    subscribe: 'subscribe'
    unsubscribe: 'unsubscribe'

  initializationMessage: (accessToken) ->
    throw new ReallyError('You should pass accessToken parameter as String') unless _.isString accessToken

    kind: 'initialization'
    data:
      cmd: @commands.init
      accessToken: accessToken

  createMessage: (res, body) ->
    throw new ReallyError('You should pass a resource parameter as String') unless _.isString res

    unless _.isObject(body) or _.isUndefined(body)
      throw new ReallyError('You should pass a body parameter as Object')

    message =
      kind: 'create'
      data:
        cmd: @commands.create
        r: res

    message['data']['body'] = body if body

    return message

  readMessage: (res, options) ->
    cmdOpts = _.omit options, (value) -> value is undefined

    supportedOptions =
      fields:
        valid: _.isArray
        message: 'You should pass Array for "fields" option'
      query:
        valid: (query) ->
          _.isObject(query) and ( _.isString(query.filter) or _.isObject(query.values) )
        message: 'You should pass Object for "query" option'
      limit:
        valid: _.isNumber
        message: 'You should pass Number for "limit" option'
      skip:
        valid: _.isNumber
        message: 'You should pass Number for "skip" option'
      sort:
        valid: _.isString
        message: 'You should pass String for "sort" option'
      token:
        valid: _.isString
        message: 'You should pass String for "token" option'
      includeTotalCount:
        valid: _.isBoolean
        message: 'You should pass Boolean for "includeTotalCount" option'
      paginationToken:
        valid: _.isString
        message: 'You should pass String for "paginationToken" option'
      subscribe:
        valid: _.isBoolean
        message: 'You should pass Boolean for "subscribe" option'

    for option, value of cmdOpts
      if option not of supportedOptions
        throw new ReallyError("The option \"#{option}\" isn't supported")

      currnetOption = supportedOptions[option]
      throw new ReallyError(currnetOption.message) unless currnetOption.valid(value)

    message =
      kind: 'read'
      data:
        cmd: @commands.read
        r: res

    message.data.cmdOpts = cmdOpts if cmdOpts

    return message

  getMessage: (res, fields) ->
    throw new ReallyError('You should pass array or nothing for fields option') unless _.isArray fields

    message =
      kind: 'get'
      data:
        cmd: @commands.get
        r: res

    if fields
      message.data.cmdOpts = fields: fields
    return message

  updateMessage: (res, rev, ops) ->
    unless _.isArray(ops) and ops.length > 0
      throw new ReallyError('You should pass at least one operation')

    supportedOperations = ['set', 'addNumber', 'push', 'addToSet', 'insertAt', 'pull', 'removeAt']
    for operation in ops
      if operation.op not in supportedOperations
        throw new ReallyError("\"#{operation.op}\" operation you passed is not supported")

    message =
      kind: 'update'
      data:
        cmd: @commands.update
        rev: rev
        r: res
        body: { ops }

    return message

  deleteMessage: (res) ->
    throw new ReallyError('You should pass a resource parameter as String') unless _.isString res

    kind: 'delete'
    data:
      cmd: @commands.delete
      r: res

  subscribeMessage: (subscriptions) ->
    unless _.isPlainObject(subscriptions) or _.isArray(subscriptions)
      throw new ReallyError('subscription(s) should be either Object or Array of Objects')

    subscriptions = [subscriptions] unless _.isArray subscriptions
    for subscription in subscriptions
      unless _.isNumber(subscription.rev) and _.isString(subscription.res)
        throw new ReallyError('You must pass string resource and number revision for subscription object')

    message =
      kind: 'subscribe'
      data:
        cmd: @commands.subscribe
        subscriptions: subscriptions

  unsubscribeMessage: (subscriptions) ->
    unless _.isPlainObject(subscriptions) or _.isArray(subscriptions)
      throw new ReallyError('subscription(s) should be either Object or Array of Objects')

    subscriptions = [subscriptions] unless _.isArray subscriptions

    for subscription in subscriptions
      unless _.isNumber(subscription.rev) and _.isString(subscription.res)
        throw new ReallyError('You must pass string resource and number revision for subscription object')

    message =
      kind: 'unsubscribe'
      data:
        cmd: @commands.unsubscribe
        subscriptions: subscriptions

  heartbeatMessage: () ->
    time = Date.now()

    kind: 'poke'
    data:
      cmd: @commands.heartbeat
      timestamp: time

  isErrorMessage: (message) -> _.has message, 'error'
