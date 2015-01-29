_ = require 'lodash'
assert = require 'power-assert'

apps = require 'apps'


describe 'apps module', ->

  it 'properties definition', ->
    assert.strictEqual typeof apps.models, 'object'
    assert.strictEqual typeof apps.subApps, 'object'

  it 'models', ->
    assert Object.keys(apps.models).length > 0
    for unused, model of apps.models
      assert typeof model is 'function'
