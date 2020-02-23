extension _Publisher {
  /// Decodes the output from upstream using a specified `TopLevelDecoder`.
  /// For example, use `JSONDecoder`.
  public func decode<Item: Decodable, Coder: _TopLevelDecoder>(type: Item.Type, decoder: Coder) -> _Publishers.Decode<Self, Item, Coder> where Self.Output == Coder.Input {
    return .init(upstream: self, decoder: decoder)
  }
}
extension _Publishers {
  public struct Decode<Upstream: _Publisher, Output: Decodable, Coder: _TopLevelDecoder>: _Publisher where Upstream.Output == Coder.Input {
    public typealias Failure = Swift.Error
    public let upstream: Upstream
    public let decoder: Coder
    public init(upstream: Upstream, decoder: Coder) {
      self.upstream = upstream
      self.decoder = decoder
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.Anonymous<Upstream.Output, Upstream.Failure, Downstream>(label: "Decode", downstream: subscriber, receiveSubscription: { (channel, subscription) in
        channel.downstream.receive(subscription: subscription)
      }, receiveThrowableValue: { (channel, value) in
        return channel.downstream.receive(try self.decoder.decode(Output.self, from: value))
      }, receiveCompletion: { (channel, completion) in
        channel.downstream.receive(completion: completion)
      })
      upstream.subscribe(midstream)
    }
  }
}
