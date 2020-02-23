@usableFromInline
final class EmbeddedSubscriber<S: _Subscriber>: AnySubscriberBox<S.Input, S.Failure> {
  private let subscriber: S
  @usableFromInline
  internal init(_ subscriber: S) {
    self.subscriber = subscriber
    super.init(combineIdentifier: subscriber.combineIdentifier)
  }
  override func receive(subscription: _Subscription) {
    subscriber.receive(subscription: subscription)
  }
  override func receive(_ input: S.Input) -> _Subscribers.Demand {
    return subscriber.receive(input)
  }
  override func receive(completion: _Subscribers.Completion<S.Failure>) {
    subscriber.receive(completion: completion)
  }
  override var description: String {
    return (subscriber as? CustomStringConvertible)?.description ?? "\(type(of: subscriber))"
  }
  override var customMirror: Mirror {
    return (subscriber as? CustomReflectable)?.customMirror ?? Mirror(subscriber, children: [])
  }
}
@usableFromInline
final class AnonymousSubscriber<Input, Failure: Swift.Error>: AnySubscriberBox<Input, Failure> {
  private let receiveSubscription: ((_Subscription) -> Void)?
  private let receiveValue: ((Input) -> _Subscribers.Demand)?
  private let receiveCompletion: ((_Subscribers.Completion<Failure>) -> Void)?
  @usableFromInline
  internal init(receiveSubscription: ((_Subscription) -> Void)? = nil, receiveValue: ((Input) -> _Subscribers.Demand)? = nil, receiveCompletion: ((_Subscribers.Completion<Failure>) -> Void)? = nil) {
    self.receiveSubscription = receiveSubscription
    self.receiveValue = receiveValue
    self.receiveCompletion = receiveCompletion
    super.init(combineIdentifier: .init())
  }
  override func receive(subscription: _Subscription) {
    receiveSubscription?(subscription)
  }
  override func receive(_ input: Input) -> _Subscribers.Demand {
    return receiveValue?(input) ?? .none
  }
  override func receive(completion: _Subscribers.Completion<Failure>) {
    receiveCompletion?(completion)
  }
  override var description: String {
    return "Anonymous AnySubscriber"
  }
  override var customMirror: Mirror {
    return Mirror(reflecting: "Anonymous AnySubscriber")
  }
}
@usableFromInline
class AnySubscriberBox<Input, Failure: Swift.Error>: _Subscriber, CustomStringConvertible, CustomReflectable {
  @usableFromInline
  internal let combineIdentifier: CombineIdentifier
  init(combineIdentifier: CombineIdentifier) {
    self.combineIdentifier = combineIdentifier
  }
  @usableFromInline
  func receive(subscription: _Subscription) {
    traffic_abstract_method()
  }
  @usableFromInline
  func receive(_: Input) -> _Subscribers.Demand {
    traffic_abstract_method()
  }
  @usableFromInline
  func receive(completion: _Subscribers.Completion<Failure>) {
    traffic_abstract_method()
  }
  @usableFromInline
  var description: String {
    traffic_abstract_method()
  }
  @usableFromInline
  var customMirror: Mirror {
    traffic_abstract_method()
  }
}
