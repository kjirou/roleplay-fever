express = require 'express'


router = express.Router()

router.get '/', (req, res) ->
  res.render 'apps/core/index'


module.exports = router
