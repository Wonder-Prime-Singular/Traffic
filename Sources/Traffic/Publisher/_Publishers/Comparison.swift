extension _Publisher where Self.Output: Comparable {
  /// Publishes the minimum value received from the upstream publisher, after it finishes.
  ///
  /// After this publisher receives a request for more than 0 items, it requests unlimited items from its upstream publisher.
  /// - Returns: A publisher that publishes the minimum value received from the upstream publisher, after the upstream publisher finishes.
  public func min() -> _Publishers.Comparison<Self> {
    return min(by: <)
  }
  /// Publishes the maximum value received from the upstream publisher, after it finishes.
  ///
  /// After this publisher receives a request for more than 0 items, it requests unlimited items from its upstream publisher.
  /// - Returns: A publisher that publishes the maximum value received from the upstream publisher, after the upstream publisher finishes.
  public func max() -> _Publishers.Comparison<Self> {
    return max(by: <)
  }
}
extension _Publisher {
  /// Publishes the minimum value received from the upstream publisher, after it finishes.
  ///
  /// After this publisher receives a request for more than 0 items, it requests unlimited items from its upstream publisher.
  /// - Parameter areInIncreasingOrder: A closure that receives two elements and returns `true` if they are in increasing order.
  /// - Returns: A publisher that publishes the minimum value received from the upstream publisher, after the upstream publisher finishes.
  public func min(by areInIncreasingOrder: @escaping (Self.Output, Self.Output) -> Bool) -> _Publishers.Comparison<Self> {
    return .init(upstream: self, areInIncreasingOrder: { (a, b) in areInIncreasingOrder(b, a) })
  }
  /// Publishes the minimum value received from the upstream publisher, using the provided error-throwing closure to order the items.
  ///
  /// After this publisher receives a request for more than 0 items, it requests unlimited items from its upstream publisher.
  /// - Parameter areInIncreasingOrder: A throwing closure that receives two elements and returns `true` if they are in increasing order. If this closure throws, the publisher terminates with a `Failure`.
  /// - Returns: A publisher that publishes the minimum value received from the upstream publisher, after the upstream publisher finishes.
  public func tryMin(by areInIncreasingOrder: @escaping (Self.Output, Self.Output) throws -> Bool) -> _Publishers.TryComparison<Self> {
    return .init(upstream: self, areInIncreasingOrder: { (a, b) in try areInIncreasingOrder(b, a) })
  }
  /// Publishes the maximum value received from the upstream publisher, using the provided ordering closure.
  ///
  /// After this publisher receives a request for more than 0 items, it requests unlimited items from its upstream publisher.
  /// - Parameter areInIncreasingOrder: A closure that receives two elements and returns `true` if they are in increasing order.
  /// - Returns: A publisher that publishes the maximum value received from the upstream publisher, after the upstream publisher finishes.
  public func max(by areInIncreasingOrder: @escaping (Self.Output, Self.Output) -> Bool) -> _Publishers.Comparison<Self> {
    return .init(upstream: self, areInIncreasingOrder: areInIncreasingOrder)
  }
  /// Publishes the maximum value received from the upstream publisher, using the provided error-throwing closure to order the items.
  ///
  /// After this publisher receives a request for more than 0 items, it requests unlimited items from its upstream publisher.
  /// - Parameter areInIncreasingOrder: A throwing closure that receives two elements and returns `true` if they are in increasing order. If this closure throws, the publisher terminates with a `Failure`.
  /// - Returns: A publisher that publishes the maximum value received from the upstream publisher, after the upstream publisher finishes.
  public func tryMax(by areInIncreasingOrder: @escaping (Self.Output, Self.Output) throws -> Bool) -> _Publishers.TryComparison<Self> {
    return .init(upstream: self, areInIncreasingOrder: areInIncreasingOrder)
  }
}
extension _Publishers {
  /// A publisher that republishes items from another publisher only if each new item is in increasing order from the previously-published item.
  public struct Comparison<Upstream: _Publisher>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Upstream.Failure
    /// The publisher that this publisher receives elements from.
    public let upstream: Upstream
    /// A closure that receives two elements and returns `true` if they are in increasing order.
    public let areInIncreasingOrder: (Upstream.Output, Upstream.Output) -> Bool
    public init(upstream: Upstream, areInIncreasingOrder: @escaping (Upstream.Output, Upstream.Output) -> Bool) {
      self.upstream = upstream
      self.areInIncreasingOrder = areInIncreasingOrder
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.Comparison(downstream: subscriber, areInIncreasingOrder: areInIncreasingOrder)
      upstream.subscribe(midstream)
    }
  }
  /// A publisher that republishes items from another publisher only if each new item is in increasing order from the previously-published item, and fails if the ordering logic throws an error.
  public struct TryComparison<Upstream: _Publisher>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Swift.Error
    /// The publisher that this publisher receives elements from.
    public let upstream: Upstream
    /// A closure that receives two elements and returns `true` if they are in increasing order.
    public let areInIncreasingOrder: (Upstream.Output, Upstream.Output) throws -> Bool
    public init(upstream: Upstream, areInIncreasingOrder: @escaping (Upstream.Output, Upstream.Output) throws -> Bool) {
      self.upstream = upstream
      self.areInIncreasingOrder = areInIncreasingOrder
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.TryComparison<Upstream.Failure, Downstream>(downstream: subscriber, areInIncreasingOrder: areInIncreasingOrder)
      upstream.subscribe(midstream)
    }
  }
}
private extension _Publishers.Channel {
  class ComparisonBase<UpstreamFailure: Swift.Error, Downstream: _Subscriber>: _Publishers.Channel.TransformBase<Downstream.Input, UpstreamFailure, Downstream> {
    let lock = Lock()
    var maximum: Downstream.Input?
    let areInIncreasingOrder: (Downstream.Input, Downstream.Input) throws -> Bool
    init(downstream: Downstream, areInIncreasingOrder: @escaping (Downstream.Input, Downstream.Input) throws -> Bool) {
      self.areInIncreasingOrder = areInIncreasingOrder
      super.init(downstream: downstream)
    }
    override func transformInput(_ input: Input) throws -> Downstream.Input? {
      return try lock.withLock {
        switch maximum {
        case .none:
          maximum = input
        case .some:
          let increasing = try self.areInIncreasingOrder(maximum!, input)
          if increasing {
            maximum = input
          }
        }
        return nil
      }
    }
    override func willComplete(completion: _Subscribers.Completion<Failure>) {
      _ = maximum.map(downstream.receive(_:))
      maximum = nil
    }
  }
  class Comparison<Downstream: _Subscriber>: ComparisonBase<Downstream.Failure, Downstream> {
    override var description: String {
      return "Comparison"
    }
  }
  class TryComparison<UpstreamFailure: Swift.Error, Downstream: _Subscriber>: ComparisonBase<UpstreamFailure, Downstream> {
    override var description: String {
      return "TryComparison"
    }
  }
}
