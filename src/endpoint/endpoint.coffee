pubSub = require '../pub_sub'

class InMemoryRemoteEndpoint

  constructor: ->
    @_isDestroyed = false


  setRPCHandler: (@_rpcHandler) ->


  handleRPCRequest: (args...) ->
    if @_isDestroyed
      throw new Error 'Endpoint already destroyed'

    @_rpcHandler args...


  publish: (contextName, [domainEventName, aggregateId]..., payload) ->
    if @_isDestroyed
      throw new Error 'Endpoint already destroyed'

    fullEventName = pubSub.getFullEventName contextName, domainEventName, aggregateId
    pubSub.publish fullEventName, payload


  destroy: ->
    Promise.resolve().then =>
      pubSub.destroy()
      @_isDestroyed = true


module.exports = new InMemoryRemoteEndpoint