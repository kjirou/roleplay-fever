_ = require 'lodash'
mongoose = require 'mongoose'
{ObjectId} = mongoose.Types
assert = require 'power-assert'

{User} = require('apps').models
{executeRemovingToEachModels} = require 'modules/mongoose-utils'


# 重複しないモデル名でモデルを作成する, 同名モデルは mongoose がエラーにするため
_uniqueModelId = 0
exports.createTestModel = (schema, callback) ->
  _uniqueModelId += 1
  Model = mongoose.model 'Test' + _uniqueModelId, schema
  # autoIndex が有効なら明示的にインデックスを張る
  # 前に dropDatabase しているとインデックスが付与されないことがあるため
  if schema.options.autoIndex
    Model.ensureIndexes (e) ->
      return callback e if e
      callback null, Model
  else
    callback null, Model

# 重複しないランダムな ObjectId を作成する
_createdObjectIdStrings = []
exports.createUniqueObjectId = ->
  letters = '0123456789abcdef'
  idStr = null
  while (not idStr?) or (idStr in _createdObjectIdStrings)
    idStr = (letters[_.random letters.length - 1] for i in [0..23]).join ''
  _createdObjectIdStrings.push idStr
  ObjectId idStr

#
# ドキュメント掃除メソッド群
#
# あるモデルとそれに関連するモデルの全ドキュメントを削除する
#
exports.purgeUsers = (callback) ->
  executeRemovingToEachModels [User], callback

# エラーオブジェクトが、指定フィールドの mongoose CastError であることを確認する
# CastError = type に反する値を入れた場合のエラー
exports.assertErrorIsMongooseCastError = (e, fieldName) ->
  assert e instanceof Error, 'Not a error'
  assert.strictEqual e.name, 'CastError'
  assert e.message.indexOf(fieldName) isnt -1, "Not a `#{fieldName}`'s error"

# エラーオブジェクトが、指定フィールドのひとつの mongoose ValidationError であることを確認する
# ValidationError = validate オプションやメソッドで指定したバリデーションのエラー
#                   required チェックなどもこちらになる
exports.assertErrorIsMongooseValidationError = (e, fieldName) ->
  assert e instanceof Error, 'Not a error'
  assert.strictEqual e.name, 'ValidationError'
  assert _.size(e.errors) is 1
  assert fieldName of e.errors, "Not a `#{fieldName}`'s error"

# doc の fieldName フィールドへ invalidValue を入れた場合、
# save 時に型違反によって正常にエラーになることを確認する
exports.assertValidMongooseFieldType = (doc, fieldName, invalidValue, callback) ->
  doc[fieldName] = invalidValue
  doc.save (e) ->
    exports.assertErrorIsMongooseCastError e, fieldName
    callback()

# doc の fieldName フィールドへ invalidValue を入れた場合、
# save 時にバリデーション違反によって正常にエラーになることを確認する
exports.assertValidMongooseFieldValidation = (doc, fieldName, invalidValue, callback) ->
  doc[fieldName] = invalidValue
  doc.save (e) ->
    exports.assertErrorIsMongooseValidationError e, fieldName
    callback()

# doc へテスト用の特異メソッドを定義する
exports.defineDocAssertions = (doc) ->
  doc.assertValidFieldType = _.partial exports.assertValidMongooseFieldType, doc
  doc.assertValidFieldValidation = _.partial exports.assertValidMongooseFieldValidation, doc
