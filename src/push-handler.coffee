module.exports =
  handle: (message) ->
    # events on objctRef and CollectionRef
    if message.r
      Really.emit message.r, message
      return
    # General events
    switch message.evt
      when 'kicked'
        console.log 'kicked'
      when 'revoked'
        console.log 'revoked'

      else
        console.log 'unknown event'

      
    
