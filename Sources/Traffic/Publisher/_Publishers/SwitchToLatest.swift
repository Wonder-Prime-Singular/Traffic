extension _Publisher where Self.Failure == Self.Output.Failure, Self.Output: _Publisher {
  /// Flattens the stream of events from multiple upstream publishers to appear as if they were coming from a single stream of events.
  ///
  /// This operator switches the inner publisher as new ones arrive but keeps the outer one constant for downstream subscribers.
  /// For example, given the type `Publisher<Publisher<Data, NSError>, Never>`, calling `switchToLatest()` will result in the type `Publisher<Data, NSError>`. The downstream subscriber sees a continuous stream of values even though they may be coming from different upstream Publishers.
  public func switchToLatest() -> _Publishers.SwitchToLatest<Self.Output, Self> {
    return .init(upstream: self)
  }
}
extension _Publishers {
  /// A publisher that “flattens” nested Publishers.
  ///
  /// Given a publisher that publishes Publishers, the `SwitchToLatest` publisher produces a sequence of events from only the most recent one.
  /// For example, given the type `Publisher<Publisher<Data, NSError>, Never>`, calling `switchToLatest()` will result in the type `Publisher<Data, NSError>`. The downstream subscriber sees a continuous stream of values even though they may be coming from different upstream Publishers.
  public struct SwitchToLatest<P: _Publisher, Upstream: _Publisher>: _Publisher where P == Upstream.Output, P.Failure == Upstream.Failure {
    public typealias Output = P.Output
    public typealias Failure = P.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// Creates a publisher that “flattens” nested Publishers.
    ///
    /// - Parameter upstream: The publisher from which this publisher receives elements.
    public init(upstream: Upstream) {
      self.upstream = upstream
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.SwitchToLatest<P, Downstream>(downstream: subscriber)
      upstream.subscribe(midstream)
    }
  }
}
private extension _Publishers.Channel {
  class SwitchToLatest<NewPublisher: _Publisher, Downstream: _Subscriber>: _Publishers.Channel.Base<NewPublisher, NewPublisher.Failure, Downstream> where Downstream.Input == NewPublisher.Output, Downstream.Failure == NewPublisher.Failure {
    var latestSubscription: _Subscription?
    let lock: Locking = Lock()
    override func receive(subscription: _Subscription) {
      guard super.shouldReceive(subscription: subscription) else {
        return
      }
      downstream.receive(subscription: self)
    }
    override func receive(_ input: Input) -> _Subscribers.Demand {
      guard super.isSubscribedAndNotCompleted() else {
        return .none
      }
      let midstream = SwitchToLatestNew(downstream: nil)
      midstream.channel = self
      input.subscribe(midstream)
      return .none
    }
    override func receive(completion: _Subscribers.Completion<Failure>) {
      guard super.shouldReceiveCompletion(completion) else {
        return
      }
      downstream.receive(completion: completion)
    }
    override func cancel() {
      guard super.shouldCancel() else {
        return
      }
      receivedSubscription()?.cancel()
      latestSubscription?.cancel()
      latestSubscription = nil
      event = .cancelled
    }
    override func request(_ demand: _Subscribers.Demand) {
      guard super.shouldRequest(demand) else {
        return
      }
      receivedSubscription()?.request(demand)
    }
    func receiveLatest(subscription: _Subscription) {
      latestSubscription?.cancel()
      latestSubscription = subscription
      subscription.request(.unlimited)
    }
    override var description: String {
      return "SwitchToLatest"
    }
    class SwitchToLatestNew: _Publishers.Channel.Base<NewPublisher.Output, NewPublisher.Failure, Downstream> {
      weak var channel: SwitchToLatest?
      var subscriptionIdentifier: CombineIdentifier = .init()
      override func receive(subscription: _Subscription) {
        guard super.shouldReceive(subscription: subscription) else {
          return
        }
        subscriptionIdentifier = subscription.combineIdentifier
        event = .subscribed(subscription: _Subscriptions.empty, completion: .pending)
        channel?.receiveLatest(subscription: subscription)
      }
      override func receive(_ input: Input) -> _Subscribers.Demand {
        guard super.isSubscribedAndNotCompleted(), subscriptionIdentifier == channel?.latestSubscription?.combineIdentifier else {
          return .none
        }
        return channel?.downstream.receive(input) ?? .none
      }
      override func receive(completion: _Subscribers.Completion<Failure>) {
        guard super.isSubscribedAndNotCompleted(), subscriptionIdentifier == channel?.latestSubscription?.combineIdentifier else {
          return
        }
        guard super.shouldReceiveCompletion(completion) else {
          return
        }
        if case .failure = completion {
          channel?.receive(completion: completion)
        }
      }
      override func request(_ demand: _Subscribers.Demand) {
        guard super.shouldRequest(demand) else {
          return
        }
        guard super.isSubscribedAndNotCompleted(), subscriptionIdentifier == channel?.latestSubscription?.combineIdentifier else {
          return
        }
        channel?.latestSubscription?.request(demand)
      }
      override var description: String {
        return "SwitchToLatest"
      }
    }
  }
}
