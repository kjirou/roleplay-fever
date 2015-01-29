_ = require 'lodash'
assert = require 'power-assert'

apps = require 'apps'


describe 'apps module', ->

  it 'properties definition', ->
    assert.strictEqual typeof apps.models, 'object'
    assert.strictEqual typeof apps.subApps, 'object'
