extension _Publisher {
  /// Republishes all elements that match a provided closure.
  ///
  /// - Parameter isIncluded: A closure that takes one element and returns a Boolean value indicating whether to republish the element.
  /// - Returns: A publisher that republishes all elements that satisfy the closure.
  public func filter(_ isIncluded: @escaping (Self.Output) -> Bool) -> _Publishers.Filter<Self> {
    return .init(upstream: self, isIncluded: isIncluded)
  }
  /// Republishes all elements that match a provided error-throwing closure.
  ///
  /// If the `isIncluded` closure throws an error, the publisher fails with that error.
  ///
  /// - Parameter isIncluded:  A closure that takes one element and returns a Boolean value indicating whether to republish the element.
  /// - Returns:  A publisher that republishes all elements that satisfy the closure.
  public func tryFilter(_ isIncluded: @escaping (Self.Output) throws -> Bool) -> _Publishers.TryFilter<Self> {
    return .init(upstream: self, isIncluded: isIncluded)
  }
}
extension _Publishers {
  /// A publisher that republishes all elements that match a provided closure.
  public struct Filter<Upstream: _Publisher>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Upstream.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// A closure that indicates whether to republish an element.
    public let isIncluded: (Upstream.Output) -> Bool
    public init(upstream: Upstream, isIncluded: @escaping (Upstream.Output) -> Bool) {
      self.upstream = upstream
      self.isIncluded = isIncluded
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.Filter(downstream: subscriber, predicate: isIncluded)
      upstream.subscribe(midstream)
    }
    public func filter(_ isIncluded: @escaping (Output) -> Bool) -> Filter<Upstream> {
      return upstream.filter(isIncluded)
    }
    public func tryFilter(_ isIncluded: @escaping (Output) throws -> Bool) -> TryFilter<Upstream> {
      return upstream.tryFilter(isIncluded)
    }
  }
  /// A publisher that republishes all elements that match a provided error-throwing closure.
  public struct TryFilter<Upstream: _Publisher>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Swift.Error
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// A error-throwing closure that indicates whether to republish an element.
    public let isIncluded: (Upstream.Output) throws -> Bool
    public init(upstream: Upstream, isIncluded: @escaping (Upstream.Output) throws -> Bool) {
      self.upstream = upstream
      self.isIncluded = isIncluded
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.TryFilter<Upstream.Failure, Downstream>(downstream: subscriber, predicate: isIncluded)
      upstream.subscribe(midstream)
    }
    public func filter(_ isIncluded: @escaping (Output) -> Bool) -> TryFilter<Upstream> {
      return upstream.tryFilter(isIncluded)
    }
    public func tryFilter(_ isIncluded: @escaping (Output) throws -> Bool) -> TryFilter<Upstream> {
      return upstream.tryFilter(isIncluded)
    }
  }
}
private extension _Publishers.Channel {
  class FilterBase2<UpstreamFailure: Swift.Error, Downstream: _Subscriber>: _Publishers.Channel.FilterBase<UpstreamFailure, Downstream> {
    let predicate: (Downstream.Input) throws -> Bool
    init(downstream: Downstream, predicate: @escaping (Downstream.Input) throws -> Bool) {
      self.predicate = predicate
      super.init(downstream: downstream)
    }
    override func filterInput(_ input: Input) throws -> Bool {
      return try predicate(input)
    }
  }
  class Filter<Downstream: _Subscriber>: FilterBase2<Downstream.Failure, Downstream> {
    override var description: String {
      return "Filter"
    }
  }
  class TryFilter<UpstreamFailure: Swift.Error, Downstream: _Subscriber>: FilterBase2<UpstreamFailure, Downstream> {
    override var description: String {
      return "TryFilter"
    }
  }
}
