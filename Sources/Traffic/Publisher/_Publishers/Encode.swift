extension _Publisher where Self.Output: Encodable {
  /// Encodes the output from upstream using a specified `TopLevelEncoder`.
  /// For example, use `JSONEncoder`.
  public func encode<Coder: _TopLevelEncoder>(encoder: Coder) -> _Publishers.Encode<Self, Coder> {
    return .init(upstream: self, encoder: encoder)
  }
}
extension _Publishers {
  public struct Encode<Upstream: _Publisher, Coder: _TopLevelEncoder>: _Publisher where Upstream.Output: Encodable {
    public typealias Failure = Swift.Error
    public typealias Output = Coder.Output
    public let upstream: Upstream
    public let encoder: Coder
    public init(upstream: Upstream, encoder: Coder) {
      self.upstream = upstream
      self.encoder = encoder
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.Anonymous<Upstream.Output, Upstream.Failure, Downstream>(label: "Encode", downstream: subscriber, receiveSubscription: { (channel, subscription) in
        channel.downstream.receive(subscription: subscription)
      }, receiveThrowableValue: { (channel, value) in
        return channel.downstream.receive(try self.encoder.encode(value))
      }, receiveCompletion: { (channel, completion) in
        channel.downstream.receive(completion: completion)
      })
      upstream.subscribe(midstream)
    }
  }
}
