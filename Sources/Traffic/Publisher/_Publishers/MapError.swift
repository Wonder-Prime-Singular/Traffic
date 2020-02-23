extension _Publisher {
  /// Converts any failure from the upstream publisher into a new error.
  ///
  /// Until the upstream publisher finishes normally or fails with an error, the returned publisher republishes all the elements it receives.
  ///
  /// - Parameter transform: A closure that takes the upstream failure as a parameter and returns a new error for the publisher to terminate with.
  /// - Returns: A publisher that replaces any upstream failure with a new error produced by the `transform` closure.
  public func mapError<E: Swift.Error>(_ transform: @escaping (Self.Failure) -> E) -> _Publishers.MapError<Self, E> {
    return .init(upstream: self, transform: transform)
  }
}
extension _Publishers {
  /// A publisher that converts any failure from the upstream publisher into a new error.
  public struct MapError<Upstream: _Publisher, Failure: Swift.Error>: _Publisher {
    public typealias Output = Upstream.Output
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// The closure that converts the upstream failure into a new error.
    public let transform: (Upstream.Failure) -> Failure
    public init(upstream: Upstream, transform: @escaping (Upstream.Failure) -> Failure) {
      self.upstream = upstream
      self.transform = transform
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.Anonymous<Upstream.Output, Upstream.Failure, Downstream>(label: "MapError", downstream: subscriber, receiveSubscription: { (channel, subscription) in
        channel.downstream.receive(subscription: subscription)
      }, receiveValue: { (channel, value) in
        return channel.downstream.receive(value)
      }, receiveCompletion: { (channel, completion) in
        channel.downstream.receive(completion: completion.mapError(transform: self.transform))
      })
      upstream.subscribe(midstream)
    }
  }
}
