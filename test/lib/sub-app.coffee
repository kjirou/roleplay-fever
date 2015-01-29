_ = require 'lodash'
assert = require 'power-assert'
request = require 'supertest'

{create, _createSubAppMiddleware, getSubAppRoot, getSubAppViewRoot
  } = require 'lib/sub-app'


describe 'sub-app module', ->

  it 'getSubAppRoot', ->
    assert /\/foo$/.test getSubAppRoot('foo')

  it 'getSubAppViewRoot', ->
    assert /\/foo$/.test getSubAppViewRoot('foo')

  it '_createSubAppMiddleware', ->
    middleware = _createSubAppMiddleware 'foo'
    assert typeof middleware is 'function'
    [req, res, next] = [{}, {}, -> ]
    middleware req, res, next
    assert typeof res.subApp.render is 'function'
    assert typeof res.subApp.renderForm is 'function'


  describe 'create', ->

    it 'should be defined properties', ->
      subApp = create 'foo'
      assert typeof subApp is 'function'
      assert /\/foo$/.test subApp.get('sub_app root')
      assert /\/foo$/.test subApp.get('sub_app view_root')
      assert typeof subApp.locals is 'object'

    it 'should be applied middleware', (done) ->
      subApp = create 'foo'
      subApp.get '/', (req, res, next) ->
        assert typeof res.subApp is 'object'
        assert typeof res.subApp.render is 'function'
        res.send 'FOO'
      request(subApp)
        .get '/'
        .expect 200
        .end (e, res) ->
          return done e if e
          assert.strictEqual res.text, 'FOO'
          done()
