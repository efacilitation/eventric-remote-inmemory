describe 'endpoint', ->

  endpoint = require './endpoint'
  pubSub = require '../pub_sub'

  describe '#destroy', ->

    it 'should call destroy on the pub sub', ->
      sandbox.spy pubSub, 'destroy'
      endpoint.destroy()
      .then ->
        expect(pubSub.destroy).to.have.been.called


    it 'should forbid any further publish operations', ->
      endpoint.destroy()
      .then ->
        expect(->
          endpoint.publish 'context', {}
        ).to.throw Error, 'Endpoint already destroyed'


    it 'should forbid any further rpc requests', ->
      rpcHandlerSpy = sandbox.spy()
      endpoint.setRPCHandler rpcHandlerSpy
      endpoint.destroy()
      .then ->
        expect(->
          endpoint.handleRPCRequest {}
        ).to.throw Error, 'Endpoint already destroyed'
        expect(rpcHandlerSpy).not.to.have.been.called
