httpErrors = require 'http-errors'
_ = require 'lodash'


@requireUser = (options={}) ->
  options = _.extend {
    redirectTo: null
  }, options

  (req, res, next) ->
    unless req.user
      if options.redirectTo?
        res.redirect options.redirectTo
      else
        next httpErrors 404
    else
      next()

@requireLogin = =>
  @requireUser
    redirectTo: '/login'
