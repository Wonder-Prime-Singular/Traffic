extension _Publishers.Last: Equatable where Upstream: Equatable {}
extension _Publisher {
  /// Only publishes the last element of a stream, after the stream finishes.
  /// - Returns: A publisher that only publishes the last element of a stream.
  public func last() -> _Publishers.Last<Self> {
    return .init(upstream: self)
  }
  /// Only publishes the last element of a stream that satisfies a predicate closure, after the stream finishes.
  /// - Parameter predicate: A closure that takes an element as its parameter and returns a Boolean value indicating whether to publish the element.
  /// - Returns: A publisher that only publishes the last element satisfying the given predicate.
  public func last(where predicate: @escaping (Self.Output) -> Bool) -> _Publishers.LastWhere<Self> {
    return .init(upstream: self, predicate: predicate)
  }
  /// Only publishes the last element of a stream that satisfies a error-throwing predicate closure, after the stream finishes.
  ///
  /// If the predicate closure throws, the publisher fails with the thrown error.
  /// - Parameter predicate: A closure that takes an element as its parameter and returns a Boolean value indicating whether to publish the element.
  /// - Returns: A publisher that only publishes the last element satisfying the given predicate.
  public func tryLast(where predicate: @escaping (Self.Output) throws -> Bool) -> _Publishers.TryLastWhere<Self> {
    return .init(upstream: self, predicate: predicate)
  }
}
extension _Publishers {
  /// A publisher that only publishes the last element of a stream, after the stream finishes.
  public struct Last<Upstream: _Publisher>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Upstream.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    public init(upstream: Upstream) {
      self.upstream = upstream
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.Last(downstream: subscriber, predicate: { _ in true })
      upstream.subscribe(midstream)
    }
  }
  /// A publisher that only publishes the last element of a stream that satisfies a predicate closure, once the stream finishes.
  public struct LastWhere<Upstream: _Publisher>: _Publisher {
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
      let midstream = Channel.LastWhere(downstream: subscriber, predicate: predicate)
      upstream.subscribe(midstream)
    }
  }
  /// A publisher that only publishes the last element of a stream that satisfies a error-throwing predicate closure, once the stream finishes.
  public struct TryLastWhere<Upstream: _Publisher>: _Publisher {
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
      let midstream = Channel.TryLastWhere<Upstream.Failure, Downstream>(downstream: subscriber, predicate: predicate)
      upstream.subscribe(midstream)
    }
  }
}
private extension _Publishers.Channel {
  class LastWhereBase<UpstreamFailure: Swift.Error, Downstream: _Subscriber>: _Publishers.Channel.FilterBase<UpstreamFailure, Downstream> {
    var last: Downstream.Input?
    let predicate: (Downstream.Input) throws -> Bool
    init(downstream: Downstream, predicate: @escaping (Downstream.Input) throws -> Bool) {
      self.predicate = predicate
      super.init(downstream: downstream)
    }
    override func filterInput(_ input: Input) throws -> Bool {
      if try predicate(input) {
        last = input
        return false
      }
      return false
    }
    override func willComplete(completion: _Subscribers.Completion<Failure>) {
      _ = last.map(downstream.receive(_:))
      last = nil
    }
  }
  class Last<Downstream: _Subscriber>: LastWhereBase<Downstream.Failure, Downstream> {
    override var description: String {
      return "Last"
    }
  }
  class LastWhere<Downstream: _Subscriber>: LastWhereBase<Downstream.Failure, Downstream> {
    override var description: String {
      return "LastWhere"
    }
  }
  class TryLastWhere<UpstreamFailure: Swift.Error, Downstream: _Subscriber>: LastWhereBase<UpstreamFailure, Downstream> {
    override var description: String {
      return "TryLastWhere"
    }
  }
}
