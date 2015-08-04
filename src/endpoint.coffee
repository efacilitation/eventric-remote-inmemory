pubSub = require './pub_sub'

class InMemoryRemoteEndpoint

  setRPCHandler: (@handleRPCRequest) ->


  publish: (contextName, [domainEventName, aggregateId]..., payload) ->
    fullEventName = pubSub.getFullEventName contextName, domainEventName, aggregateId
    pubSub.publish fullEventName, payload


module.exports = new InMemoryRemoteEndpoint