extension _Publisher where Self.Failure == Never {
  /// Assigns each element from a Publisher to a property on an object.
  ///
  /// - Parameters:
  ///   - keyPath: The key path of the property to assign.
  ///   - object: The object on which to assign the value.
  /// - Returns: A cancellable instance; used when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.
  public func assign<Root>(to keyPath: ReferenceWritableKeyPath<Root, Output>, on object: Root) -> _AnyCancellable {
    let subscriber = _Subscribers.Assign(object: object, keyPath: keyPath)
    subscribe(subscriber)
    return _AnyCancellable(subscriber)
  }
}
extension _Subscribers {
  /// A simple subscriber that requests an unlimited number of values upon subscription.
  public final class Assign<Root, Input>: _Subscriber, _Cancellable, CustomStringConvertible, CustomReflectable {
    public typealias Failure = Never
    public private(set) var object: Root?
    public let keyPath: ReferenceWritableKeyPath<Root, Input>
    private var event: SubscriberEvent = .pending
    public init(object: Root, keyPath: ReferenceWritableKeyPath<Root, Input>) {
      self.object = object
      self.keyPath = keyPath
    }
    public func receive(subscription: _Subscription) {
      guard .pending == event else {
        return
      }
      self.event = .subscribed(subscription: subscription, completion: .pending)
      subscription.request(.unlimited)
    }
    public func receive(_ input: Input) -> _Subscribers.Demand {
      guard event.isSubscribed && !event.isCompleted else {
        return .none
      }
      object?[keyPath: keyPath] = input
      return .none
    }
    public func receive(completion: _Subscribers.Completion<Failure>) {
      guard let subscription = event.embededSubscription, !event.isCompleted else {
        return
      }
      self.event = .subscribed(subscription: subscription, isFinished: completion.isFinished)
    }
    public func cancel() {
      guard let subscription = event.embededSubscription else {
        return
      }
      subscription.cancel()
      event = .cancelled
    }
    public var description: String {
      return "Assign"
    }
    public var customMirror: Mirror {
      return Mirror(self, children: [])
    }
  }
}
