extension _Publisher {
  /// Omits the specified number of elements before republishing subsequent elements.
  ///
  /// - Parameter count: The number of elements to omit.
  /// - Returns: A publisher that does not republish the first `count` elements.
  public func dropFirst(_ count: Int = 1) -> _Publishers.Drop<Self> {
    return .init(upstream: self, count: count)
  }
}
extension _Publishers {
  /// A publisher that omits a specified number of elements before republishing later elements.
  public struct Drop<Upstream: _Publisher>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Upstream.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// The number of elements to drop.
    public let count: Int
    public init(upstream: Upstream, count: Int) {
      self.upstream = upstream
      self.count = count
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      var count = 0
      let midstream = Channel.Anonymous<Upstream.Output, Upstream.Failure, Downstream>(label: "Drop", downstream: subscriber, receiveSubscription: { (channel, subscription) in
        channel.downstream.receive(subscription: subscription)
      }, receiveValue: { (channel, value) in
        if count < self.count {
          count += 1
          return .none
        }
        _ = channel.downstream.receive(value)
        return .unlimited
      }, receiveCompletion: { (channel, completion) in
        channel.downstream.receive(completion: completion)
      })
      upstream.subscribe(midstream)
    }
  }
}
extension _Publishers.Drop: Equatable where Upstream: Equatable {
}
