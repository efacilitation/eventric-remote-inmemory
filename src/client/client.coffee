endpoint = require '../endpoint'
pubSub = require '../pub_sub'

class InMemoryRemoteClient

  rpc: (rpcRequest) ->
    new Promise (resolve, reject) ->
      endpoint.handleRPCRequest rpcRequest, (error, result) ->
        if error
          reject error
        else
          resolve result


  subscribe: (contextName, [domainEventName, aggregateId]..., handlerFunction) ->
    fullEventName = pubSub.getFullEventName contextName, domainEventName, aggregateId
    pubSub.subscribe fullEventName, handlerFunction


  unsubscribe: (subscriberId) ->
    pubSub.unsubscribe subscriberId


module.exports = new InMemoryRemoteClient