apps = require 'apps'
_ = require 'lodash'
assert = require 'power-assert'


describe 'apps module', ->

  it 'models', ->
    assert Object.keys(apps.models).length > 0
    for unused, model of apps.models
      assert typeof model is 'function'
