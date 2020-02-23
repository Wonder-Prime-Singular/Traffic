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
    let lock: Lock = Lock()
    var maxPublishers: _Subscribers.Demand
    let transform: (Input) -> NewPublisher
    var subscribedCount: Int = 0
    var completedCount: Int = 0
    var subscriptions: [_Subscription] = []
    var upstreamFailed: Bool = false
    var newPublisherFailed: Bool = false
    func checkAllCompleted() {
      if subscribedCount == completedCount {
        downstream.receive(completion: .finished)
      }
    }
    init<Upstream: _Publisher>(flatMap: _Publishers.FlatMap<NewPublisher, Upstream>, downstream: Downstream) where Upstream.Output == Input {
      self.transform = flatMap.transform
      self.maxPublishers = flatMap.maxPublishers
      super.init(downstream: downstream)
    }
    override func receive(subscription: _Subscription) {
      guard super.shouldReceive(subscription: subscription) else {
        return
      }
      lock.withLock {
        subscribedCount += 1
      }
      downstream.receive(subscription: self)
      subscription.request(maxPublishers)
    }
    override func receive(_ input: Input) -> _Subscribers.Demand {
      guard super.isSubscribedAndNotCompleted() else {
        return .none
      }
      if maxPublishers > .none {
        maxPublishers -= 1
        let newPublisher = transform(input)
        let newMidstream = FlatMapNew(downstream: nil)
        newMidstream.channel = self
        newPublisher.subscribe(newMidstream)
        return .none
      } else {
        return .none
      }
    }
    override func receive(completion: _Subscribers.Completion<Failure>) {
      guard super.shouldReceiveCompletion(completion) else {
        return
      }
      if case .failure = completion {
        upstreamFailed = true
        downstream.receive(completion: completion)
      } else {
        lock.withLock {
          completedCount += 1
          checkAllCompleted()
        }
      }
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
      receivedSubscription()?.request(demand)
    }
    func receiveNew(subscription: _Subscription) {
      lock.withLock {
        subscribedCount += 1
      }
      subscriptions.append(subscription)
      subscription.request(.unlimited)
    }
    func receiveNew(_ input: NewPublisher.Output) -> _Subscribers.Demand {
      return downstream.receive(input)
    }
    func receiveNew(completion: _Subscribers.Completion<NewPublisher.Failure>) {
      if case .failure = completion {
        newPublisherFailed = true
        downstream.receive(completion: completion)
      } else {
        maxPublishers += 1
        lock.withLock {
          completedCount += 1
          checkAllCompleted()
        }
      }
    }
    override var description: String {
      return "FlatMap"
    }
    class FlatMapNew: _Publishers.Channel.Base<NewPublisher.Output, NewPublisher.Failure, Downstream> {
      weak var channel: FlatMap?
      override func receive(subscription: _Subscription) {
        guard super.shouldReceive(subscription: subscription) else {
          return
        }
        guard channel?.isSubscribedAndNotCompleted() == true else {
          return
        }
        channel?.receiveNew(subscription: subscription)
      }
      override func receive(_ input: Input) -> _Subscribers.Demand {
        guard super.isSubscribedAndNotCompleted() else {
          return .none
        }
        return channel?.receiveNew(input) ?? .none
      }
      override func receive(completion: _Subscribers.Completion<Failure>) {
        guard super.shouldReceiveCompletion(completion) else {
          return
        }
        channel?.receiveNew(completion: completion)
      }
      override var description: String {
        return "FlatMap"
      }
    }
  }
}
