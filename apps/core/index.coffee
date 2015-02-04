httpErrors = require 'http-errors'
_ = require 'lodash'
passport = require 'passport'

{create} = require 'lib/sub-app'
{ErrorReporter} = require 'modules/validator'


app = create 'core'


app.get '/', (req, res) ->
  res.subApp.render 'index'

app.all '/login', (req, res, next) ->
  inputs = _.extend {
    email: ''
    password: ''
  }, req.body

  switch req.method
    when 'GET'
      res.subApp.renderForm 'login'
    when 'POST'
      authMiddleware = passport.authenticate 'local', (e, user) ->
        if e
          next e
        else unless user
          reporter = new ErrorReporter
          reporter.error 'email', 'Invalid email or password'
          res.subApp.renderForm 'login',
            inputs: inputs
            error: reporter
        else
          req.login user, (e) ->
            return next e if e
            #res.redirect '/home'
            res.redirect '/'
      authMiddleware req, res, next
    else
      next httpErrors 404

app.all '/logout', (req, res, next) ->
  req.logout()
  res.redirect '/'


module.exports = app
