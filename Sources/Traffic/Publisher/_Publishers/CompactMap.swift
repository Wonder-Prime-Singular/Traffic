extension _Publisher {
  /// Calls a closure with each received element and publishes any returned optional that has a value.
  ///
  /// - Parameter transform: A closure that receives a value and returns an optional value.
  /// - Returns: A publisher that republishes all non-`nil` results of calling the transform closure.
  public func compactMap<T>(_ transform: @escaping (Self.Output) -> T?) -> _Publishers.CompactMap<Self, T> {
    return .init(upstream: self, transform: transform)
  }
  /// Calls an error-throwing closure with each received element and publishes any returned optional that has a value.
  ///
  /// If the closure throws an error, the publisher cancels the upstream and sends the thrown error to the downstream receiver as a `Failure`.
  /// - Parameter transform: an error-throwing closure that receives a value and returns an optional value.
  /// - Returns: A publisher that republishes all non-`nil` results of calling the transform closure.
  public func tryCompactMap<T>(_ transform: @escaping (Self.Output) throws -> T?) -> _Publishers.TryCompactMap<Self, T> {
    return .init(upstream: self, transform: transform)
  }
}
extension _Publishers {
  /// A publisher that republishes all non-`nil` results of calling a closure with each received element.
  public struct CompactMap<Upstream: _Publisher, Output>: _Publisher {
    public typealias Failure = Upstream.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// A closure that receives values from the upstream publisher and returns optional values.
    public let transform: (Upstream.Output) -> Output?
    public init(upstream: Upstream, transform: @escaping (Upstream.Output) -> Output?) {
      self.upstream = upstream
      self.transform = transform
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.CompactMap(downstream: subscriber, transform: transform)
      upstream.subscribe(midstream)
    }
    public func compactMap<T>(_ transform: @escaping (Output) -> T?) -> CompactMap<Upstream, T> {
      return upstream.compactMap { (value) in self.transform(value).flatMap(transform) }
    }
    public func map<T>(_ transform: @escaping (Output) -> T) -> CompactMap<Upstream, T> {
      return upstream.compactMap { (value) in self.transform(value).map(transform) }
    }
  }
  /// A publisher that republishes all non-`nil` results of calling an error-throwing closure with each received element.
  public struct TryCompactMap<Upstream: _Publisher, Output>: _Publisher {
    public typealias Failure = Swift.Error
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// An error-throwing closure that receives values from the upstream publisher and returns optional values.
    ///
    /// If this closure throws an error, the publisher fails.
    public let transform: (Upstream.Output) throws -> Output?
    public init(upstream: Upstream, transform: @escaping (Upstream.Output) throws -> Output?) {
      self.upstream = upstream
      self.transform = transform
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.TryCompactMap<Upstream.Output, Upstream.Failure, Downstream>(downstream: subscriber, transform: transform)
      upstream.subscribe(midstream)
    }
    public func compactMap<T>(_ transform: @escaping (Output) throws -> T?) -> TryCompactMap<Upstream, T> {
      return upstream.tryCompactMap { (value) in try self.transform(value).flatMap(transform) }
    }
  }
}
private extension _Publishers.Channel {
  class CompactMapBase<UpstreamOutput, UpstreamFailure: Swift.Error, Downstream: _Subscriber>: _Publishers.Channel.TransformBase<UpstreamOutput, UpstreamFailure, Downstream> {
    let transform: (UpstreamOutput) throws -> Downstream.Input?
    init(downstream: Downstream, transform: @escaping (UpstreamOutput) throws -> Downstream.Input?) {
      self.transform = transform
      super.init(downstream: downstream)
    }
    override func transformInput(_ input: Input) throws -> Downstream.Input? {
      return try transform(input)
    }
  }
  class CompactMap<UpstreamOutput, Downstream: _Subscriber>: CompactMapBase<UpstreamOutput, Downstream.Failure, Downstream> {
    override var description: String {
      return "CompactMap"
    }
  }
  class TryCompactMap<UpstreamOutput, UpstreamFailure: Swift.Error, Downstream: _Subscriber>: CompactMapBase<UpstreamOutput, UpstreamFailure, Downstream> {
    override var description: String {
      return "TryCompactMap"
    }
  }
}
