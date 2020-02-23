extension _Publisher {
  /// Publishes the number of elements received from the upstream publisher.
  ///
  /// - Returns: A publisher that consumes all elements until the upstream publisher finishes, then emits a single
  /// value with the total number of elements received.
  public func count() -> _Publishers.Count<Self> {
    return .init(upstream: self)
  }
}
extension _Publishers {
  /// A publisher that publishes the number of elements received from the upstream publisher.
  public struct Count<Upstream: _Publisher>: _Publisher {
    public typealias Output = Int
    public typealias Failure = Upstream.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    public init(upstream: Upstream) {
      self.upstream = upstream
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      var count: Int = 0
      let lock = Lock()
      let midstream = Channel.Anonymous<Upstream.Output, Upstream.Failure, Downstream>(label: "Count", downstream: subscriber, receiveSubscription: { (channel, subscription) in
        channel.downstream.receive(subscription: subscription)
      }, receiveValue: { (channel, value) in
        lock.withLock {
          count += 1
          return channel.downstream.receive(count)
        }
      }, receiveCompletion: { (channel, completion) in
        channel.downstream.receive(completion: completion)
      })
      upstream.subscribe(midstream)
    }
  }
}
extension _Publishers.Count: Equatable where Upstream: Equatable {
}
