/// A type-erasing subscriber.
///
/// Use an `AnySubscriber` to wrap an existing subscriber whose details you don’t want to expose.
/// You can also use `AnySubscriber` to create a custom subscriber by providing closures for `Subscriber`’s methods, rather than implementing `Subscriber` directly.
public struct _AnySubscriber<Input, Failure: Swift.Error>: _Subscriber, CustomStringConvertible, CustomReflectable {
  public var combineIdentifier: CombineIdentifier {
    return subscriber.combineIdentifier
  }
  @usableFromInline
  internal let subscriber: AnySubscriberBox<Input, Failure>
  /// Creates a type-erasing subscriber to wrap an existing subscriber.
  ///
  /// - Parameter s: The subscriber to type-erase.
  @inlinable
  public init<S: _Subscriber>(_ s: S) where Input == S.Input, Failure == S.Failure {
    subscriber = EmbeddedSubscriber(s)
  }
  @inlinable
  public init<S: _Subject>(_ s: S) where Input == S.Output, Failure == S.Failure {
    self.init(SubjectSubscriber(s))
  }
  /// Creates a type-erasing subscriber that executes the provided closures.
  ///
  /// - Parameters:
  ///   - receiveSubscription: A closure to execute when the subscriber receives the initial subscription from the publisher.
  ///   - receiveValue: A closure to execute when the subscriber receives a value from the publisher.
  ///   - receiveCompletion: A closure to execute when the subscriber receives a completion callback from the publisher.
  @inlinable
  public init(receiveSubscription: ((_Subscription) -> Void)? = nil, receiveValue: ((Input) -> _Subscribers.Demand)? = nil, receiveCompletion: ((_Subscribers.Completion<Failure>) -> Void)? = nil) {
    subscriber = AnonymousSubscriber<Input, Failure>(receiveSubscription: receiveSubscription, receiveValue: receiveValue, receiveCompletion: receiveCompletion)
  }
  public func receive(subscription: _Subscription) {
    subscriber.receive(subscription: subscription)
  }
  public func receive(_ input: Input) -> _Subscribers.Demand {
    return subscriber.receive(input)
  }
  public func receive(completion: _Subscribers.Completion<Failure>) {
    subscriber.receive(completion: completion)
  }
  public var description: String {
    return subscriber.description
  }
  public var customMirror: Mirror {
    return subscriber.customMirror
  }
}
