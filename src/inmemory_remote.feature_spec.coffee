describe 'inmemory remote', ->

  inmemoryRemote = require './'

  describe 'executing a rpc from the client', ->

    it 'should call the rpc request handler from the endpoint', ->
      rpcHandlerStub = sandbox.stub().yields()
      inmemoryRemote.endpoint.setRPCHandler rpcHandlerStub
      rpcRequest = {}
      inmemoryRemote.client.rpc rpcRequest
      .then ->
        expect(rpcHandlerStub).to.have.been.calledWith rpcRequest


  describe 'publishing an event from the endpoint', ->

    it 'should inform all subscribers for this event', (done) ->
      payload = {}
      inmemoryRemote.client.subscribe 'Context', 'SomeEvent', 'aggregate-1', (receivedPayload) ->
        expect(receivedPayload).to.equal payload
        done()
      inmemoryRemote.endpoint.publish 'Context', 'SomeEvent', 'aggregate-1', payload