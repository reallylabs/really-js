###*
 * really
 * name space for application the parent for object & collection functions
###

Transport = require './transports/webSocket'
ReallyObject = require './really-object'
ReallyCollection = require './really-collection'
ReallyError = require './really-error'
_ = require 'lodash'
PushHandler = require './push-handler'

store = {}
class Really
  constructor: (domain, accessToken, options) ->
    unless domain and accessToken
      throw new ReallyError('Can\'t initialize Really without passing domain and access token')

    unless _.isString(domain) and _.isString(accessToken)
      throw new ReallyError('Only <String> values are allowed for domain and access token')

    if store[domain]
      @object = store[domain]['object']
      @collection = store[domain]['collection']
      @transport = store[domain]['transport']
    else
      store[domain] = {}
      @transport = new Transport(domain, accessToken, options)
      @transport.connect()
      store[domain]['transport'] = @transport
      @object = store[domain]['object'] = new ReallyObject(@transport)
      @collection = store[domain]['collection'] = new ReallyCollection(@transport)
      @transport.on 'message', (message) =>
        PushHandler.handle(this, message) unless _.has message, 'tag'

    return this

module.exports = Really
  
