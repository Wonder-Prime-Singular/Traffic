extension _Publisher {
  /// Omits elements from the upstream publisher until a given closure returns false, before republishing all remaining elements.
  ///
  /// - Parameter predicate: A closure that takes an element as a parameter and returns a Boolean
  /// value indicating whether to drop the element from the publisher’s output.
  /// - Returns: A publisher that skips over elements until the provided closure returns `false`.
  public func drop(while predicate: @escaping (Self.Output) -> Bool) -> _Publishers.DropWhile<Self> {
    return .init(upstream: self, predicate: predicate)
  }
  /// Omits elements from the upstream publisher until an error-throwing closure returns false, before republishing all remaining elements.
  ///
  /// If the predicate closure throws, the publisher fails with an error.
  ///
  /// - Parameter predicate: A closure that takes an element as a parameter and returns a Boolean value indicating whether to drop the element from the publisher’s output.
  /// - Returns: A publisher that skips over elements until the provided closure returns `false`, and then republishes all remaining elements. If the predicate closure throws, the publisher fails with an error.
  public func tryDrop(while predicate: @escaping (Self.Output) throws -> Bool) -> _Publishers.TryDropWhile<Self> {
    return .init(upstream: self, predicate: predicate)
  }
}
extension _Publishers {
  /// A publisher that omits elements from an upstream publisher until a given closure returns false.
  public struct DropWhile<Upstream: _Publisher>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Upstream.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// The closure that indicates whether to drop the element.
    public let predicate: (Upstream.Output) -> Bool
    public init(upstream: Upstream, predicate: @escaping (Output) -> Bool) {
      self.upstream = upstream
      self.predicate = predicate
    }
    public func receive<S: _Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
      DropWhileWrapper(upstream: upstream, predicate: predicate).receive(label: "DropWhile", subscriber: subscriber)
    }
  }
  /// A publisher that omits elements from an upstream publisher until a given error-throwing closure returns false.
  public struct TryDropWhile<Upstream: _Publisher>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Swift.Error
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// The error-throwing closure that indicates whether to drop the element.
    public let predicate: (Upstream.Output) throws -> Bool
    public init(upstream: Upstream, predicate: @escaping (Output) throws -> Bool) {
      self.upstream = upstream
      self.predicate = predicate
    }
    public func receive<S: _Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
      DropWhileWrapper(upstream: upstream, predicate: predicate).receive(label: "TryDropWhile", subscriber: subscriber)
    }
  }
  private struct DropWhileWrapper<Upstream: _Publisher> {
    public typealias Output = Upstream.Output
    public let upstream: Upstream
    public let predicate: (Upstream.Output) throws -> Bool
    public init(upstream: Upstream, predicate: @escaping (Output) throws -> Bool) {
      self.upstream = upstream
      self.predicate = predicate
    }
    public func receive<Downstream: _Subscriber>(label: String, subscriber: Downstream) where Downstream.Input == Output {
      var drop = false
      let midstream = Channel.Anonymous<Upstream.Output, Upstream.Failure, Downstream>(label: label, downstream: subscriber, receiveSubscription: { (channel, subscription) in
        channel.downstream.receive(subscription: subscription)
      }, receiveThrowableValue: { (channel, value) in
        drop = try drop || !self.predicate(value)
        if !drop {
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
