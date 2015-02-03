_ = require 'lodash'
httpErrors = require 'http-errors'

logics = require './logics'
models = require './models'
{User} = models
{create} = require 'lib/sub-app'


app = create 'user'
app.models = models

defaultInputs =
  email: ''
  password: ''


app.all '/create', (req, res, next) ->
  inputs = _.extend {}, defaultInputs, req.body

  switch req.method
    when 'GET'
      res.subApp.renderForm 'create'
    when 'POST'
      logics.postUser null, inputs, (e, any) ->
        if e
          next e
        else if any instanceof User
          res.redirect '/'
          #req.login any, (e) ->
          #  return next e if e
          #  #req.xflash 'success', 'Update was completed.'
          #  res.redirect '/'
        else
          res.subApp.renderForm 'create',
            inputs: inputs
            error: any.reporter
    else
      next httpErrors 404


module.exports = app


#{requireLogin} = require 'lib/middlewares/authentication'
#{requireObjectId} = require 'lib/middlewares/core'
#
#
#controllers['update/:id'] = chain requireLogin(), requireObjectId(User), (req, res, next) ->
#  inputs = _.extend {}, defaultInputs, req.body
#
#  switch req.method
#    when 'GET'
#      res.subApp.renderForm 'update',
#        inputs: _.pick req.doc.toObject(), 'email'
#    when 'POST'
#      logics.postUser req.doc, inputs, (e, any) ->
#        if e
#          next e
#        else if any instanceof User
#          req.xflash 'success', 'Update was completed.'
#          res.redirect req.path
#        else
#          res.subApp.renderForm 'update',
#            inputs: inputs
#            error: any.reporter
#    else
#      next new Http404Error
#
#
#module.exports = controllers
