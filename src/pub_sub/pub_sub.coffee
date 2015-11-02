# TODO: Consider making a separate pub sub module. This is very similar to eventric/event_bus
class PubSub

  constructor: ->
    @_subscribers = []
    @_subscriberId = 0
    @_publishQueue = Promise.resolve()
    @_isDestroyed = false


  subscribe: (eventName, subscriberFunction) ->
    Promise.resolve().then =>
      subscriber =
        eventName: eventName
        subscriberFunction: subscriberFunction
        subscriberId: @_getNextSubscriberId()
      @_subscribers.push subscriber
      return subscriber.subscriberId


  _getNextSubscriberId: ->
    @_subscriberId++


  publish: (eventName, payload) ->
    new Promise (resolve, reject) =>
      @_verifyPublishIsPossible eventName, payload

      publishOperation = =>
        @_notifySubscribers eventName, payload
        .then(resolve).catch(reject)

      @_enqueuePublishing publishOperation


  _verifyPublishIsPossible: (eventName, payload) ->
    if @_isDestroyed
      errorMessage = """
        PubSub was destroyed, cannot publish #{eventName}
        with payload #{JSON.stringify payload}
      """
      throw new Error errorMessage


  _notifySubscribers: (eventName, payload) ->
    Promise.resolve()
    .then =>
      subscribers = @_getRelevantSubscribers eventName
      Promise.all subscribers.map (subscriber) -> subscriber.subscriberFunction payload


  _getRelevantSubscribers: (eventName) ->
    if not eventName
      return @_subscribers

    return @_subscribers.filter (subscriber) -> subscriber.eventName is eventName


  _enqueuePublishing: (publishOperation) ->
    @_publishQueue = @_publishQueue.then publishOperation


  unsubscribe: (subscriberId) ->
    Promise.resolve().then =>
      @_subscribers = @_subscribers.filter (subscriber) -> subscriber.subscriberId isnt subscriberId


  getFullEventName: (eventParts...) ->
    eventParts = eventParts.filter (eventPart) -> eventPart?
    return eventParts.join '/'


  destroy: ->
    @_waitForPublishQueue().then =>
      @_isDestroyed = true


  _waitForPublishQueue: ->
    publishQueue = @_publishQueue
    publishQueue.then =>
      if @_publishQueue isnt publishQueue
        @_waitForPublishQueue()



module.exports = new PubSub