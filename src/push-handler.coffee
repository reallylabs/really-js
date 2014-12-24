ReallyError = require './really-error'

module.exports =
  handle: (really, message = {}) ->
    {r, evt} = message
    switch evt
      when 'updated', 'deleted' then really.object.emit "#{r}:#{evt}", message
      when 'created' then really.collection.emit "#{r}:#{evt}", message
      when 'kicked', 'revoked' then really.emit evt, message
      else throw new ReallyError("Unknown event: #{evt}")
