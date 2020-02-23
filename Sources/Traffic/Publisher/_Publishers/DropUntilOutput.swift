extension _Publisher {
  /// Ignores elements from the upstream publisher until it receives an element from a second publisher.
  ///
  /// This publisher requests a single value from the upstream publisher, and it ignores (drops) all elements from that publisher until the upstream publisher produces a value. After the `other` publisher produces an element, this publisher cancels its subscription to the `other` publisher, and allows events from the `upstream` publisher to pass through.
  /// After this publisher receives a subscription from the upstream publisher, it passes through backpressure requests from downstream to the upstream publisher. If the upstream publisher acts on those requests before the other publisher produces an item, this publisher drops the elements it receives from the upstream publisher.
  ///
  /// - Parameter publisher: A publisher to monitor for its first emitted element.
  /// - Returns: A publisher that drops elements from the upstream publisher until the `other` publisher produces a value.
  public func drop<P: _Publisher>(untilOutputFrom publisher: P) -> _Publishers.DropUntilOutput<Self, P> where Self.Failure == P.Failure {
    return .init(upstream: self, other: publisher)
  }
}
extension _Publishers {
  /// A publisher that ignores elements from the upstream publisher until it receives an element from second publisher.
  public struct DropUntilOutput<Upstream: _Publisher, Other: _Publisher>: _Publisher where Upstream.Failure == Other.Failure {
    public typealias Output = Upstream.Output
    public typealias Failure = Upstream.Failure
    /// The publisher that this publisher receives elements from.
    public let upstream: Upstream
    /// A publisher to monitor for its first emitted element.
    public let other: Other
    /// Creates a publisher that ignores elements from the upstream publisher until it receives an element from another publisher.
    ///
    /// - Parameters:
    ///   - upstream: A publisher to drop elements from while waiting for another publisher to emit elements.
    ///   - other: A publisher to monitor for its first emitted element.
    public init(upstream: Upstream, other: Other) {
      self.upstream = upstream
      self.other = other
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let lock = Lock()
      var drop = true
      let otherMidstream = Channel.Anonymous<Other.Output, Other.Failure, Downstream>(label: "DropUntilOutput", downstream: subscriber, receiveSubscription: { (channel, subscription) in
        channel.downstream.receive(subscription: subscription)
      }, receiveValue: { (channel, value) in
        lock.withLock {
          drop = false
        }
        return .none
      }, receiveCompletion: { (channel, completion) in
        channel.downstream.receive(completion: completion)
      })
      other.subscribe(otherMidstream)
      let midstream = Channel.Anonymous<Upstream.Output, Upstream.Failure, Downstream>(label: "DropUntilOutput", downstream: subscriber, receiveSubscription: { (channel, subscription) in
        channel.downstream.receive(subscription: subscription)
      }, receiveValue: { (channel, value) in
        if !lock.withLock { drop } {
          _ = channel.downstream.receive(value)
          return .none
        } else {
          return .unlimited
        }
      }, receiveCompletion: { (channel, completion) in
        channel.downstream.receive(completion: completion)
      })
      upstream.subscribe(midstream)
    }
  }
}
extension _Publishers.DropUntilOutput: Equatable where Upstream: Equatable, Other: Equatable {}
