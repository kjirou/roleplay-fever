{create} = require 'lib/sub-app'


app = create 'core'


app.get '/', (req, res) ->
  res.send 'respond with a resource'


module.exports = app
