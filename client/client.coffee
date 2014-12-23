Really =  require '../src/really.coffee'

really = new Really('ws://localhost:1337', 'token')

really.collection.create '/users/*',
  body:
    name: 'Ihab'
.done (data) ->
  console.log data

really.collection.read '/users/*',
  query:
    fiter: 'name=$name'
    values: {name: "Ihab"}
.done (data) ->
  console.log data

really.object.get '/users/123',
  fields: ['name', 'age']
.done (data) ->
  console.log data

really.object.delete('/users/123').done (data) -> console.log data

really.object.update '/users/123', 23,
  ops: [
    f: 'name'
    val: 'Ihab'
    op: 'set'
  ]
.done (data) ->
  console.log data
