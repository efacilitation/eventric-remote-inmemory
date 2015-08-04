require('es6-promise').polyfill()

chai     = require 'chai'
sinon     = require 'sinon'
sinonChai = require 'sinon-chai'
chai.use sinonChai

root = if window? then window else global
root.expect = chai.expect
root.sandbox   = sinon.sandbox.create()


afterEach ->
  sandbox.restore()