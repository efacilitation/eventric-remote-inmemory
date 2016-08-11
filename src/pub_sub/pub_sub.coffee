class PubSub

  constructor: ->
    @_subscribers = []
    @_subscriberId = 0


  subscribe: (eventName, subscriberFunction) ->
    new Promise (resolve) =>
      subscriber =
        eventName: eventName
        subscriberFunction: subscriberFunction
        subscriberId: @_getNextSubscriberId()
      @_subscribers.push subscriber
      resolve subscriber.subscriberId


  publish: (eventName, payload) ->
    subscribers = @_getRelevantSubscribers eventName
    return Promise.all subscribers.map (subscriber) ->
      return subscriber.subscriberFunction payload


  _getRelevantSubscribers: (eventName) ->
    if eventName
      @_subscribers.filter (subscriber) -> subscriber.eventName is eventName
    else
      @_subscribers


  unsubscribe: (subscriberId) ->
    new Promise (resolve) =>
      @_subscribers = @_subscribers.filter (subscriber) -> subscriber.subscriberId isnt subscriberId
      resolve()


  _getNextSubscriberId: ->
    @_subscriberId++


  getFullEventName: (eventParts...) ->
    eventParts = eventParts.filter (eventPart) -> eventPart?
    return eventParts.join '/'


module.exports = new PubSub
