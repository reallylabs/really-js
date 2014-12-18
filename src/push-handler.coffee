module.exports =
  handle: (message) ->
    # events on object and collection
    if message.r
      Really.emit message.r, message
      Really.emit "#{message.r}:#{message.cmd}", message
      return
    # General events
    switch message.evt
      when 'kicked'
        console.log 'kicked'
      when 'revoked'
        console.log 'revoked'
      else
        console.log 'unknown event'

      
    
