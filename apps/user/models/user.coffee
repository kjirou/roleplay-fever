_ = require 'lodash'
mongoose = require 'mongoose'
{Schema} = mongoose
randomString = require 'random-string'

{definePlugins} = require 'lib/mongoose-plugins'
{generateHashedPassword} = require 'lib/crypto'


consts =
  SALT_LENGTH: 20


schema = new Schema {
  email:
    type: String
    index:
      unique: true
      sparse: true

  # ハッシュ化されたパスワード
  password:
    type: String
    required: true

  salt:
    type: String
    default: ->
      randomString length:consts.SALT_LENGTH
}

definePlugins schema, 'core', 'createdAt', 'updatedAt'

_.extend schema.statics, consts


schema.statics.queryActiveUsers = -> @where()

schema.statics.queryActiveUserByEmail = (email) ->
  @queryActiveUsers().where({email: email}).findOne()


schema.methods.setPassword = (rawPassword) ->
  @password = generateHashedPassword rawPassword, @salt

schema.methods.verifyPassword = (rawPassword) ->
  @password is generateHashedPassword rawPassword, @salt


exports.User = mongoose.model 'User', schema
