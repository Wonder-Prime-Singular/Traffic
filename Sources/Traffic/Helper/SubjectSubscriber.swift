public class SubjectSubscriber<Downstream: _Subject>: _Subscriber, CustomStringConvertible, CustomReflectable, CustomPlaygroundDisplayConvertible, _Subscription {
  public typealias Input = Downstream.Output
  public typealias Failure = Downstream.Failure
  private var downstream: Downstream?
  private var event: SubscriberEvent = .pending
  public let combineIdentifier: CombineIdentifier
  @usableFromInline
  init(_ downstream: Downstream) {
    self.downstream = downstream
    combineIdentifier = CombineIdentifier(downstream)
  }
  public func receive(subscription: _Subscription) {
    guard !event.isSubscribed else {
      return
    }
    event = .subscribed(subscription: subscription, completion: .pending)
    downstream?.send(subscription: self)
  }
  public func receive(_ input: Input) -> _Subscribers.Demand {
    downstream?.send(input)
    return .none
  }
  public func receive(completion: _Subscribers.Completion<Failure>) {
    guard let subscription = event.embededSubscription else {
      return
    }
    downstream?.send(completion: completion)
    event = .subscribed(subscription: subscription, isFinished: completion.isFinished)
    downstream = nil
  }
  public var description: String {
    return "Subject"
  }
  public var customMirror: Mirror {
    return Mirror(self, children: [])
  }
  public var playgroundDescription: Any {
    return description
  }
  public func request(_ demand: _Subscribers.Demand) {
    event.embededSubscription?.request(demand)
  }
  public func cancel() {
    guard !event.isCancelled else {
      return
    }
    event.embededSubscription?.cancel()
    event = .cancelled
  }
}
