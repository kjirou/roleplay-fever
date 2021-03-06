_ = require 'lodash'

DEFAULT_ERROR_MESSAGES = require './default-error-messages'
ErrorReporter = require './error-reporter'
validator = require './validator'

{Field} = require('./fields')(validator, DEFAULT_ERROR_MESSAGES)
{Form} = require('./forms')(ErrorReporter)


# mongoose の validate に設定する値を生成する、API は mongoose-validator を真似ている
# わざわざ作ったのは mongoose-validator は自分が読み込んでいる validatorjs を使うため
# Ref) https://github.com/leepowellcouk/mongoose-validator
createValidator = (settings) ->
  settings = _.extend {
    # e.g. 'isInt'
    validator: undefined
    arguments: []
    message: null
    # 値が '' なら成功判定
    passIfEmpty: false
    # 値が null or undefined なら成功判定
    # 入力値からは入らない想定だが、初期値から入ることがある
    passIfNull: false
  }, settings

  # Ref) http://mongoosejs.com/docs/api.html#schematype_SchemaType-validate
  {
    validator: (value) ->
      settings.passIfEmpty and value is '' or
      settings.passIfNull and (not value?) or
        validator[settings.validator].apply validator, [value].concat(settings.arguments)
    msg: settings.message ? DEFAULT_ERROR_MESSAGES[settings.validator] ? DEFAULT_ERROR_MESSAGES.isInvalid
  }


module.exports =
  createValidator: createValidator
  DEFAULT_ERROR_MESSAGES: DEFAULT_ERROR_MESSAGES
  ErrorReporter: ErrorReporter
  Field: Field
  Form: Form
  validator: validator
