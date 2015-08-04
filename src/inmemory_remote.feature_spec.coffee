describe 'inmemory remote', ->

  inmemoryRemote = require './index'

  describe 'executing a rpc from the client', ->

    it 'should call the rpc request handler from the endpoint', ->
      rpcHandlerStub = sandbox.stub().yields()
      inmemoryRemote.endpoint.setRPCHandler rpcHandlerStub
      rpcRequest = {}
      inmemoryRemote.client.rpc rpcRequest
      .then ->
        expect(rpcHandlerStub).to.have.been.calledWith rpcRequest