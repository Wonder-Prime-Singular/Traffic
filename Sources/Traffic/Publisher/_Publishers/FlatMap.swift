extension _Publisher {
  /// Transforms all elements from an upstream publisher into a new or existing publisher.
  ///
  /// `flatMap` merges the output from all returned publishers into a single stream of output.
  ///
  /// - Parameters:
  ///   - maxPublishers: The maximum number of publishers produced by this method.
  ///   - transform: A closure that takes an element as a parameter and returns a publisher
  /// that produces elements of that type.
  /// - Returns: A publisher that transforms elements from an upstream publisher into
  /// a publisher of that element’s type.
  public func flatMap<T, P: _Publisher>(maxPublishers: _Subscribers.Demand = .unlimited, _ transform: @escaping (Self.Output) -> P) -> _Publishers.FlatMap<P, Self> where T == P.Output, Self.Failure == P.Failure {
    return .init(upstream: self, maxPublishers: maxPublishers, transform: transform)
  }
}
extension _Publishers {
  public struct FlatMap<NewPublisher: _Publisher, Upstream: _Publisher>: _Publisher where NewPublisher.Failure == Upstream.Failure {
    public typealias Output = NewPublisher.Output
    public typealias Failure = Upstream.Failure
    public let upstream: Upstream
    public var maxPublishers: _Subscribers.Demand
    public let transform: (Upstream.Output) -> NewPublisher
    public init(upstream: Upstream, maxPublishers: _Subscribers.Demand, transform: @escaping (Upstream.Output) -> NewPublisher) {
      self.upstream = upstream
      self.maxPublishers = maxPublishers
      self.transform = transform
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.FlatMap<NewPublisher, Upstream.Output, Downstream>(flatMap: self, downstream: subscriber)
      upstream.subscribe(midstream)
    }
  }
}
private extension _Publishers.Channel {
  class FlatMap<NewPublisher: _Publisher, UpstreamOutput, Downstream: _Subscriber>: _Publishers.Channel.Base<UpstreamOutput, NewPublisher.Failure, Downstream> where NewPublisher.Output == Downstream.Input, NewPublisher.Failure == Downstream.Failure {
    let lock: Locking = RecursiveLock()
    let maxPublishers: _Subscribers.Demand
    let transform: (Input) -> NewPublisher
    var pendingSubscriptionCount: Int = 0
    var subscriptions: [_Subscription] = []
    var upstreamCompleted: Bool = false
    var newPublisherFailed: Bool = false
    init<Upstream: _Publisher>(flatMap: _Publishers.FlatMap<NewPublisher, Upstream>, downstream: Downstream) where Upstream.Output == Input {
      self.transform = flatMap.transform
      self.maxPublishers = flatMap.maxPublishers
      super.init(downstream: downstream)
    }
    override func receive(subscription: _Subscription) {
      guard super.shouldReceive(subscription: subscription) else {
        return
      }
      downstream.receive(subscription: self)
      subscription.request(maxPublishers)
    }
    override func receive(_ input: Input) -> _Subscribers.Demand {
      guard super.isSubscribedAndNotCompleted() else {
        return .none
      }
      pendingSubscriptionCount += 1
      let newPublisher = transform(input)
      let newMidstream = FlatMapNew(downstream: nil)
      newMidstream.channel = self
      newPublisher.subscribe(newMidstream)
      return .none
    }
    override func receive(completion: _Subscribers.Completion<Failure>) {
      upstreamCompleted = true
      if case .failure = completion {
        guard super.shouldReceiveCompletion(completion) else {
          return
        }
        downstream.receive(completion: completion)
      } else {
        lock.withLock {
          _ = isAllCompleted()
        }
      }
    }
    func isAllCompleted() -> Bool {
      if upstreamCompleted && subscriptions.isEmpty && pendingSubscriptionCount == 0 {
        let completion = _Subscribers.Completion<Failure>.finished
        guard super.shouldReceiveCompletion(completion) else {
          return true
        }
        downstream.receive(completion: completion)
        return true
      }
      return false
    }
    override func cancel() {
      guard super.shouldCancel() else {
        return
      }
      self.subscriptions.forEach { (subscription) in
        subscription.cancel()
      }
      receivedSubscription()?.cancel()
      event = .cancelled
    }
    override func request(_ demand: _Subscribers.Demand) {
      guard super.shouldRequest(demand) else {
        return
      }
      self.demand += demand
    }
    func receiveNew(subscription: _Subscription, id: CombineIdentifier) {
      pendingSubscriptionCount -= 1
      subscriptions.append(subscription)
      if self.demand == .unlimited {
        subscription.request(.unlimited)
      } else {
        subscription.request(.max(1))
      }
    }
    func receiveNew(_ input: NewPublisher.Output, id: CombineIdentifier) -> _Subscribers.Demand {
      self.demand += downstream.receive(input)
      self.demand -= 1
      return .none
    }
    func receiveNew(completion: _Subscribers.Completion<NewPublisher.Failure>, id: CombineIdentifier) {
      if case .failure = completion {
        newPublisherFailed = true
        for s in subscriptions where s.combineIdentifier != id {
          s.cancel()
        }
        subscriptions.removeAll()
        downstream.receive(completion: completion)
      } else {
        if let index = subscriptions.firstIndex(where: { $0.combineIdentifier == id }) {
          subscriptions.remove(at: index)
        }
        lock.withLock {
          if !isAllCompleted(), maxPublishers != .unlimited {
            receivedSubscription()?.request(.max(1))
          }
        }
      }
    }
    override var description: String {
      return "FlatMap"
    }
    class FlatMapNew: _Publishers.Channel.Base<NewPublisher.Output, NewPublisher.Failure, Downstream> {
      var subscriptionId: CombineIdentifier = .init()
      weak var channel: FlatMap?
      override func receive(subscription: _Subscription) {
        subscriptionId = subscription.combineIdentifier
        channel?.receiveNew(subscription: subscription, id: subscriptionId)
      }
      override func receive(_ input: Input) -> _Subscribers.Demand {
        return channel?.receiveNew(input, id: subscriptionId) ?? .none
      }
      override func receive(completion: _Subscribers.Completion<Failure>) {
        channel?.receiveNew(completion: completion, id: subscriptionId)
      }
      override var description: String {
        return "FlatMap"
      }
    }
  }
}
