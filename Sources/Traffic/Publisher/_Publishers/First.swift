extension _Publishers.First: Equatable where Upstream: Equatable {}
extension _Publisher {
  /// Publishes the first element of a stream, then finishes.
  ///
  /// If this publisher doesn’t receive any elements, it finishes without publishing.
  /// - Returns: A publisher that only publishes the first element of a stream.
  public func first() -> _Publishers.First<Self> {
    return .init(upstream: self)
  }
  /// Publishes the first element of a stream to satisfy a predicate closure, then finishes.
  ///
  /// The publisher ignores all elements after the first. If this publisher doesn’t receive any elements, it finishes without publishing.
  /// - Parameter predicate: A closure that takes an element as a parameter and returns a Boolean value that indicates whether to publish the element.
  /// - Returns: A publisher that only publishes the first element of a stream that satifies the predicate.
  public func first(where predicate: @escaping (Self.Output) -> Bool) -> _Publishers.FirstWhere<Self> {
    return .init(upstream: self, predicate: predicate)
  }
  /// Publishes the first element of a stream to satisfy a throwing predicate closure, then finishes.
  ///
  /// The publisher ignores all elements after the first. If this publisher doesn’t receive any elements, it finishes without publishing. If the predicate closure throws, the publisher fails with an error.
  /// - Parameter predicate: A closure that takes an element as a parameter and returns a Boolean value that indicates whether to publish the element.
  /// - Returns: A publisher that only publishes the first element of a stream that satifies the predicate.
  public func tryFirst(where predicate: @escaping (Self.Output) throws -> Bool) -> _Publishers.TryFirstWhere<Self> {
    return .init(upstream: self, predicate: predicate)
  }
}
extension _Publishers {
  /// A publisher that publishes the first element of a stream, then finishes.
  public struct First<Upstream: _Publisher>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Upstream.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    public init(upstream: Upstream) {
      self.upstream = upstream
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.First(downstream: subscriber, predicate: { _ in true })
      upstream.subscribe(midstream)
    }
  }
  /// A publisher that only publishes the first element of a stream to satisfy a predicate closure.
  public struct FirstWhere<Upstream: _Publisher>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Upstream.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// The closure that determines whether to publish an element.
    public let predicate: (Upstream.Output) -> Bool
    public init(upstream: Upstream, predicate: @escaping (Output) -> Bool) {
      self.upstream = upstream
      self.predicate = predicate
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.FirstWhere(downstream: subscriber, predicate: predicate)
      upstream.subscribe(midstream)
    }
  }
  /// A publisher that only publishes the first element of a stream to satisfy a throwing predicate closure.
  public struct TryFirstWhere<Upstream: _Publisher>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Swift.Error
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// The error-throwing closure that determines whether to publish an element.
    public let predicate: (Upstream.Output) throws -> Bool
    public init(upstream: Upstream, predicate: @escaping (Output) throws -> Bool) {
      self.upstream = upstream
      self.predicate = predicate
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.TryFirstWhere<Upstream.Failure, Downstream>(downstream: subscriber, predicate: predicate)
      upstream.subscribe(midstream)
    }
  }
}
private extension _Publishers.Channel {
  class FirstWhereBase<UpstreamFailure: Swift.Error, Downstream: _Subscriber>: _Publishers.Channel.FilterBase<UpstreamFailure, Downstream> {
    let predicate: (Downstream.Input) throws -> Bool
    init(downstream: Downstream, predicate: @escaping (Downstream.Input) throws -> Bool) {
      self.predicate = predicate
      super.init(downstream: downstream)
    }
    override func filterInput(_ input: Input) throws -> Bool {
      if try predicate(input) {
        _ = downstream.receive(input)
        receive(completion: .finished)
        return false
      }
      return false
    }
  }
  class First<Downstream: _Subscriber>: FirstWhereBase<Downstream.Failure, Downstream> {
    override var description: String {
      return "First"
    }
  }
  class FirstWhere<Downstream: _Subscriber>: FirstWhereBase<Downstream.Failure, Downstream> {
    override var description: String {
      return "FirstWhere"
    }
  }
  class TryFirstWhere<UpstreamFailure: Swift.Error, Downstream: _Subscriber>: FirstWhereBase<UpstreamFailure, Downstream> {
    override var description: String {
      return "TryFirstWhere"
    }
  }
}
