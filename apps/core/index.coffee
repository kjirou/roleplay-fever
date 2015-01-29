{create} = require 'lib/sub-app'


app = create 'core'


app.get '/', (req, res) ->
  res.subApp.render 'index'


module.exports = app
