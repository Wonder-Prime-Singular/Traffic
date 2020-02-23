extension _Publisher {
  /// Attaches a subscriber with closure-based behavior.
  ///
  /// This method creates the subscriber and immediately requests an unlimited number of values, prior to returning the subscriber.
  /// - parameter receiveComplete: The closure to execute on completion.
  /// - parameter receiveValue: The closure to execute on receipt of a value.
  /// - Returns: A cancellable instance; used when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.
  public func sink(receiveCompletion: @escaping (_Subscribers.Completion<Self.Failure>) -> Void, receiveValue: @escaping (Self.Output) -> Void) -> _AnyCancellable {
    let subscriber = _Subscribers.Sink<Self.Output, Self.Failure>(receiveCompletion: receiveCompletion, receiveValue: receiveValue)
    subscribe(subscriber)
    return _AnyCancellable(subscriber)
  }
}
extension _Publisher where Self.Failure == Never {
  /// Attaches a subscriber with closure-based behavior.
  ///
  /// This method creates the subscriber and immediately requests an unlimited number of values, prior to returning the subscriber.
  /// - parameter receiveValue: The closure to execute on receipt of a value.
  /// - Returns: A cancellable instance; used when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.
  public func sink(receiveValue: @escaping (Self.Output) -> Void) -> _AnyCancellable {
    return sink(receiveCompletion: { (_) in }, receiveValue: receiveValue)
  }
}
extension _Subscribers {
  /// A simple subscriber that requests an unlimited number of values upon subscription.
  public final class Sink<Input, Failure: Swift.Error>: _Subscriber, _Cancellable, CustomStringConvertible, CustomReflectable {
    /// The closure to execute on receipt of a value.
    public let receiveValue: (Input) -> Void
    /// The closure to execute on completion.
    public let receiveCompletion: (_Subscribers.Completion<Failure>) -> Void
    private var event: SubscriberEvent = .pending
    /// Initializes a sink with the provided closures.
    ///
    /// - Parameters:
    ///   - receiveCompletion: The closure to execute on completion.
    ///   - receiveValue: The closure to execute on receipt of a value.
    public init(receiveCompletion: @escaping ((_Subscribers.Completion<Failure>) -> Void), receiveValue: @escaping ((Input) -> Void)) {
      self.receiveCompletion = receiveCompletion
      self.receiveValue = receiveValue
    }
    public func receive(subscription: _Subscription) {
      guard .pending == event else {
        return
      }
      self.event = .subscribed(subscription: subscription, completion: .pending)
      subscription.request(.unlimited)
    }
    public func receive(_ input: Input) -> _Subscribers.Demand {
      receiveValue(input)
      return .none
    }
    public func receive(completion: _Subscribers.Completion<Failure>) {
      guard let subscription = event.embededSubscription else {
        return
      }
      event = .subscribed(subscription: subscription, isFinished: completion.isFinished)
      receiveCompletion(completion)
    }
    public func cancel() {
      guard let subscription = event.embededSubscription else {
        return
      }
      subscription.cancel()
      event = .cancelled
    }
    public var description: String {
      return "Sink"
    }
    public var customMirror: Mirror {
      return Mirror(self, children: [])
    }
  }
}
