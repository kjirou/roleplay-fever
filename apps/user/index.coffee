{create} = require 'lib/sub-app'


app = create 'user'
models = app.models = require './models'


app.get '/', (req, res) ->
  res.send 'respond with a resource'


module.exports = app
