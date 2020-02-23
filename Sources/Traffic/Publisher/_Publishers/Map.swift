extension _Publisher {
  public func map<T>(_ transform: @escaping (Self.Output) -> T) -> _Publishers.Map<Self, T> {
    return .init(upstream: self, transform: transform)
  }
  /// Transforms all elements from the upstream publisher with a provided error-throwing closure.
  ///
  /// If the `transform` closure throws an error, the publisher fails with the thrown error.
  /// - Parameter transform: A closure that takes one element as its parameter and returns a new element.
  /// - Returns: A publisher that uses the provided closure to map elements from the upstream publisher to new elements that it then publishes.
  public func tryMap<T>(_ transform: @escaping (Self.Output) throws -> T) -> _Publishers.TryMap<Self, T> {
    return .init(upstream: self, transform: transform)
  }
}
extension _Publishers {
  /// A publisher that transforms all elements from the upstream publisher with a provided closure.
  public struct Map<Upstream: _Publisher, Output>: _Publisher {
    public typealias Failure = Upstream.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// The closure that transforms elements from the upstream publisher.
    public let transform: (Upstream.Output) -> Output
    public init(upstream: Upstream, transform: @escaping (Upstream.Output) -> Output) {
      self.upstream = upstream
      self.transform = transform
    }
    public func receive<S: _Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
      let midstream = Channel.Map(downstream: subscriber, transform: transform)
      upstream.subscribe(midstream)
    }
    public func map<T>(_ transform: @escaping (Output) -> T) -> Map<Upstream, T> {
      return upstream.map { (value) in transform(self.transform(value)) }
    }
    public func tryMap<T>(_ transform: @escaping (Output) throws -> T) -> TryMap<Upstream, T> {
      return upstream.tryMap { (value) in try transform(self.transform(value)) }
    }
  }
  /// A publisher that transforms all elements from the upstream publisher with a provided error-throwing closure.
  public struct TryMap<Upstream: _Publisher, Output>: _Publisher {
    public typealias Failure = Swift.Error
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// The error-throwing closure that transforms elements from the upstream publisher.
    public let transform: (Upstream.Output) throws -> Output
    public init(upstream: Upstream, transform: @escaping (Upstream.Output) throws -> Output) {
      self.upstream = upstream
      self.transform = transform
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.TryMap<Upstream.Output, Upstream.Failure, Downstream>(downstream: subscriber, transform: transform)
      upstream.subscribe(midstream)
    }
    public func map<T>(_ transform: @escaping (Output) -> T) -> TryMap<Upstream, T> {
      return upstream.tryMap { (value) in transform(try self.transform(value)) }
    }
    public func tryMap<T>(_ transform: @escaping (Output) throws -> T) -> TryMap<Upstream, T> {
      return upstream.tryMap { (value) in try transform(try self.transform(value)) }
    }
  }
}
private extension _Publishers.Channel {
  class MapBase<UpstreamOutput, UpstreamFailure: Swift.Error, Downstream: _Subscriber>: _Publishers.Channel.TransformBase<UpstreamOutput, UpstreamFailure, Downstream> {
    let transform: (UpstreamOutput) throws -> Downstream.Input
    init(downstream: Downstream, transform: @escaping (UpstreamOutput) throws -> Downstream.Input) {
      self.transform = transform
      super.init(downstream: downstream)
    }
    override func transformInput(_ input: Input) throws -> Downstream.Input? {
      return try transform(input)
    }
  }
  class Map<UpstreamOutput, Downstream: _Subscriber>: MapBase<UpstreamOutput, Downstream.Failure, Downstream> {
    override var description: String {
      return "Map"
    }
  }
  class TryMap<UpstreamOutput, UpstreamFailure: Swift.Error, Downstream: _Subscriber>: MapBase<UpstreamOutput, UpstreamFailure, Downstream> {
    override var description: String {
      return "TryMap"
    }
  }
}
