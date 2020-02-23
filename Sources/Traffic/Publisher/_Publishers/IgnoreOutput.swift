extension _Publisher {
  /// Ingores all upstream elements, but passes along a completion state (finished or failed).
  ///
  /// The output type of this publisher is `Never`.
  /// - Returns: A publisher that ignores all upstream elements.
  public func ignoreOutput() -> _Publishers.IgnoreOutput<Self> {
    return .init(upstream: self)
  }
}
extension _Publishers {
  /// A publisher that ignores all upstream elements, but passes along a completion state (finish or failed).
  public struct IgnoreOutput<Upstream: _Publisher>: _Publisher {
    public typealias Output = Never
    public typealias Failure = Upstream.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    public init(upstream: Upstream) {
      self.upstream = upstream
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.Anonymous<Upstream.Output, Upstream.Failure, Downstream>(label: "IgnoreOutput", downstream: subscriber, receiveSubscription: { (channel, subscription) in
        channel.downstream.receive(subscription: subscription)
      }, receiveValue: { (channel, value) in
        return .none
      }, receiveCompletion: { (channel, completion) in
        channel.downstream.receive(completion: completion)
      })
      upstream.subscribe(midstream)
    }
  }
}
extension _Publishers.IgnoreOutput: Equatable where Upstream: Equatable {
}
