async = require 'async'
_ = require 'lodash'

{getSubAppRoot} = require 'lib/sub-app'


#
# Sub Applications
#
subApps = {}
[
  'core'
  'home'
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
do ({core, home, user}=subApps) ->
  core.use '/home', home
  core.use '/user', user


module.exports =
  models: models
  subApps: subApps
