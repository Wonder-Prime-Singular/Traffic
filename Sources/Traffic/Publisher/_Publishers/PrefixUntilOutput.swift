extension _Publisher {
  /// Republishes elements until another publisher emits an element.
  ///
  /// After the second publisher publishes an element, the publisher returned by this method finishes.
  ///
  /// - Parameter publisher: A second publisher.
  /// - Returns: A publisher that republishes elements until the second publisher publishes an element.
  public func prefix<P: _Publisher>(untilOutputFrom publisher: P) -> _Publishers.PrefixUntilOutput<Self, P> {
    return .init(upstream: self, other: publisher)
  }
}
extension _Publishers {
  public struct PrefixUntilOutput<Upstream: _Publisher, Other: _Publisher>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Upstream.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// Another publisher, whose first output causes this publisher to finish.
    public let other: Other
    public init(upstream: Upstream, other: Other) {
      self.upstream = upstream
      self.other = other
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let lock = Lock()
      var finish = false
      let otherMidstream = Channel.Anonymous<Other.Output, Other.Failure, Downstream>(label: "PrefixUntilOutput", downstream: subscriber, receiveSubscription: { (channel, subscription) in
        channel.downstream.receive(subscription: subscription)
      }, receiveValue: { (channel, value) in
        lock.withLock {
          finish = true
        }
        return .none
      }, receiveCompletion: nil)
      other.subscribe(otherMidstream)
      let midstream = Channel.Anonymous<Upstream.Output, Upstream.Failure, Downstream>(label: "PrefixUntilOutput", downstream: subscriber, receiveSubscription: { (channel, subscription) in
        channel.downstream.receive(subscription: subscription)
      }, receiveValue: { (channel, value) in
        if !lock.withLock { finish } {
          return channel.downstream.receive(value)
        } else {
          return .none
        }
      }, receiveCompletion: { (channel, completion) in
        channel.downstream.receive(completion: completion)
      })
      upstream.subscribe(midstream)
    }
  }
}
