httpErrors = require 'http-errors'
_ = require 'lodash'

{requireLogin} = require 'lib/middlewares/authentication'
{create} = require 'lib/sub-app'
{ErrorReporter} = require 'modules/validator'


app = create 'home'

app.use requireLogin()


app.get '/', (req, res) ->
  res.subApp.render 'index'


module.exports = app
