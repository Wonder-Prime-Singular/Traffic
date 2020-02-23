extension _Publisher where Self.Output: Equatable {
  /// Publishes a Boolean value upon receiving an element equal to the argument.
  ///
  /// The contains publisher consumes all received elements until the upstream publisher produces a matching element. At that point, it emits `true` and finishes normally. If the upstream finishes normally without producing a matching element, this publisher emits `false`, then finishes.
  /// - Parameter output: An element to match against.
  /// - Returns: A publisher that emits the Boolean value `true` when the upstream publisher emits a matching value.
  public func contains(_ output: Self.Output) -> _Publishers.Contains<Self> {
    return .init(upstream: self, output: output)
  }
}
extension _Publishers {
  /// A publisher that emits a Boolean value when a specified element is received from its upstream publisher.
  public struct Contains<Upstream: _Publisher>: _Publisher where Upstream.Output: Equatable {
    public typealias Output = Bool
    public typealias Failure = Upstream.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// The element to scan for in the upstream publisher.
    public let output: Upstream.Output
    public init(upstream: Upstream, output: Upstream.Output) {
      self.upstream = upstream
      self.output = output
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.Anonymous<Upstream.Output, Upstream.Failure, Downstream>(label: "Contains", downstream: subscriber, receiveSubscription: { (channel, subscription) in
        channel.downstream.receive(subscription: subscription)
      }, receiveValue: { (channel, value) in
        channel.downstream.receive(value == self.output)
      }, receiveCompletion: { (channel, completion) in
        channel.downstream.receive(completion: completion)
      })
      upstream.subscribe(midstream)
    }
  }
}
extension _Publishers.Contains: Equatable where Upstream: Equatable {}
