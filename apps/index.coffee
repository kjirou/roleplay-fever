async = require 'async'
_ = require 'lodash'

{getSubAppRoot} = require 'lib/sub-app'


#
# Sub Applications
#
subApps = {}
[
  'core'
  'user'
].forEach (subAppName) ->
  subApps[subAppName] = require getSubAppRoot subAppName


#
# Models
#
models = {}
for unused, subApp of subApps
  _.extend models, subApp.models ? {}


#
# Routing
#
do ({core, user}=subApps) ->
  core.use '/user', user


module.exports =
  models: models
  subApps: subApps
