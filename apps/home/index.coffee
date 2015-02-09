httpErrors = require 'http-errors'
_ = require 'lodash'

{create} = require 'lib/sub-app'
{ErrorReporter} = require 'modules/validator'


app = create 'home'


app.get '/', (req, res) ->
  res.subApp.render 'index'


module.exports = app
