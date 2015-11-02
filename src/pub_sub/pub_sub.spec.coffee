describe 'PubSub', ->

  pubSub = null

  beforeEach ->
    delete require.cache[require.resolve './pub_sub']
    pubSub = require './pub_sub'


  describe '#subscribe', ->
    it 'should return a unique subscriber id', ->
      firstSubscribe = pubSub.subscribe 'SomeEvent', ->
      secondSubscribe = pubSub.subscribe 'SomeEvent', ->

      Promise.all [firstSubscribe, secondSubscribe]
      .then ([subscriberId1, subscriberId2]) ->
        expect(subscriberId1).to.be.a 'number'
        expect(subscriberId2).to.be.a 'number'
        expect(subscriberId1).not.to.equal subscriberId2


  describe '#publish', ->

    it 'should call a subscriber function with the event payload given it subscribed for the matching event name', ->
      payload = {}
      subscriberFunction = sandbox.stub()
      pubSub.subscribe 'event', subscriberFunction
      .then ->
        pubSub.publish 'event', payload
      .then ->
        expect(subscriberFunction).to.have.been.calledWith payload


    it 'should call all subscriber functions given they all subscribed for the matching event name', ->
      payload = {}
      subscriberFunction = sandbox.stub()
      anotherSubscriberFunction = sandbox.stub()
      pubSub.subscribe 'event', subscriberFunction
      .then ->
        pubSub.subscribe 'event', anotherSubscriberFunction
      .then ->
        pubSub.publish 'event', payload
      .then ->
        expect(subscriberFunction).to.have.been.called
        expect(anotherSubscriberFunction).to.have.been.called


    it 'should not call a subscriber function given it subscribed for an event with another name', ->
      payload = {}
      subscriberFunction = sandbox.stub()
      pubSub.subscribe 'event2', subscriberFunction
      .then ->
        pubSub.publish 'event1', payload
      .then ->
        expect(subscriberFunction).to.have.not.been.called


    it 'should reject with an error given the subscriber function throws an error', ->
      payload = {}
      thrownError = new Error
      subscriberFunction = -> throw thrownError
      pubSub.subscribe 'event', subscriberFunction
      .then ->
        pubSub.publish 'event', payload
      .catch (receivedError) ->
        expect(receivedError).to.equal thrownError


    it 'should reject with an error given the subscriber function rejects with an error', ->
      payload = {}
      rejectedError = new Error
      subscriberFunction = -> Promise.reject rejectedError
      pubSub.subscribe 'event', subscriberFunction
      .then ->
        pubSub.publish 'event', payload
      .catch (receivedError) ->
        expect(receivedError).to.equal rejectedError


    it 'should wait to resolve given the subscriber function takes some time to resolve', ->
      payload = {}
      subscriberFunctionHasFinished = false
      subscriberFunction = ->
        new Promise (resolve) ->
          setTimeout ->
            subscriberFunctionHasFinished = true
            resolve()
          , 15
      pubSub.subscribe 'event', subscriberFunction
      .then ->
        pubSub.publish 'event', payload
      .then ->
        expect(subscriberFunctionHasFinished).to.be.true


    it 'should wait to publish the event given a previous publish operation is not finished yet', ->
      payload1 = {}
      payload2 = {}

      subscriberFinishedFunction = sandbox.stub()
      subscriberFunction = ->
        new Promise (resolve) ->
          setTimeout ->
            subscriberFinishedFunction()
            resolve()
          , 15

      anotherSubscriberFunction = sandbox.stub()

      pubSub.subscribe 'event1', subscriberFunction
      .then ->
        pubSub.subscribe 'event2', anotherSubscriberFunction
      .then ->
        pubSub.publish 'event1', payload1
        pubSub.publish 'event2', payload2
      .then ->
        expect(subscriberFinishedFunction).to.have.been.calledBefore anotherSubscriberFunction


    it 'should publish the event although a previous publish operation has failed', ->
      payload1 = {}
      payload2 = {}
      subscriberFunction = -> Promise.reject new Error
      anotherSubscriberFunction = sandbox.stub()
      pubSub.subscribe 'event1', subscriberFunction
      .then ->
        pubSub.subscribe 'event2', anotherSubscriberFunction
      .then ->
        pubSub.publish 'event1', payload1
        pubSub.publish 'event2', payload2
      .then ->
        expect(anotherSubscriberFunction).to.have.been.called


    it 'should not call the subscriber function given it unsubscribed after subscribing', ->
      payload = {}
      subscriberFunction = sandbox.stub()
      pubSub.subscribe 'event', subscriberFunction
      .then (subscriberId) ->
        pubSub.unsubscribe subscriberId
      .then ->
        pubSub.publish 'event', payload
      .then ->
        expect(subscriberFunction).to.have.not.been.called


  describe 'destroying the pub sub', ->

    it 'should reject with an error when publishing after destroying the pub sub', ->
      payload = foo: 'bar'
      pubSub.destroy()
      .then ->
        pubSub.publish 'event', payload
      .catch (error) ->
        expect(error).to.be.an.instanceOf Error
        expect(error.message).to.match /"foo"\s*:"bar"/


    it 'should wait to resolve given a previous publish operation has not finished yet', ->
      payload = {}

      subscriberFinishedFunction = sandbox.stub()
      subscriberFunction = ->
        new Promise (resolve) ->
          setTimeout ->
            subscriberFinishedFunction()
            resolve()
          , 15

      pubSub.subscribe 'event', subscriberFunction
      .then ->
        pubSub.publish 'event', payload
        pubSub.destroy()
      .then ->
        expect(subscriberFinishedFunction).to.have.been.called


    it 'should wait to resolve given a previous ongoing publish operation will trigger another publish operation', ->
      payload1 = {}
      payload2 = {}

      handleFunction =  ->
        new Promise (resolve) ->
          setTimeout ->
            pubSub.publish 'event2', payload2
            resolve()
          , 15
      anotherSubscriberFunction = sandbox.stub()

      pubSub.subscribe 'event1', handleFunction
      .then ->
        pubSub.subscribe 'event2', anotherSubscriberFunction
      .then ->
        pubSub.publish 'event1', payload1
        pubSub.destroy()
      .then ->
        expect(anotherSubscriberFunction).to.have.been.called

