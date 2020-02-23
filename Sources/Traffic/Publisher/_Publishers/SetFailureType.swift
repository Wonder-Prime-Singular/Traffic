extension _Publisher where Self.Failure == Never {
  /// Changes the failure type declared by the upstream publisher.
  ///
  /// The publisher returned by this method cannot actually fail with the specified type and instead just finishes normally. Instead, you use this method when you need to match the error types of two mismatched Publishers.
  ///
  /// - Parameter failureType: The `Failure` type presented by this publisher.
  /// - Returns: A publisher that appears to send the specified failure type.
  public func setFailureType<E: Swift.Error>(to: E.Type) -> _Publishers.SetFailureType<Self, E> {
    return .init(upstream: self)
  }
}
extension _Publishers {
  /// A publisher that appears to send a specified failure type.
  ///
  /// The publisher cannot actually fail with the specified type and instead just finishes normally. Use this publisher type when you need to match the error types for two mismatched Publishers.
  public struct SetFailureType<Upstream: _Publisher, Failure: Swift.Error>: _Publisher where Upstream.Failure == Never {
    public typealias Output = Upstream.Output
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// Creates a publisher that appears to send a specified failure type.
    ///
    /// - Parameter upstream: The publisher from which this publisher receives elements.
    public init(upstream: Upstream) {
      self.upstream = upstream
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.Anonymous<Upstream.Output, Upstream.Failure, Downstream>(label: "SetFailureType", downstream: subscriber, receiveSubscription: { (channel, subscription) in
        channel.downstream.receive(subscription: subscription)
      }, receiveValue: { (channel, value) in
        return channel.downstream.receive(value)
      }, receiveCompletion: { (channel, completion) in
        channel.downstream.receive(completion: completion.mapError(transform: { (error) in error as! Failure }))
      })
      upstream.subscribe(midstream)
    }
    public func setFailureType<E: Swift.Error>(to: E.Type) -> SetFailureType<Upstream, E> {
      return upstream.setFailureType(to: E.self)
    }
  }
}
extension _Publishers.SetFailureType: Equatable where Upstream: Equatable {}
