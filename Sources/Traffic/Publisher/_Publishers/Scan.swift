extension _Publisher {
  /// Transforms elements from the upstream publisher by providing the current element to a closure along with the last value returned by the closure.
  ///
  ///     let pub = (0...5)
  ///         .publisher
  ///         .scan(0, { return $0 + $1 })
  ///         .sink(receiveValue: { print ("\($0)", terminator: " ") })
  ///      // Prints "0 1 3 6 10 15 ".
  ///
  ///
  /// - Parameters:
  ///   - initialResult: The previous result returned by the `nextPartialResult` closure.
  ///   - nextPartialResult: A closure that takes as its arguments the previous value returned by the closure and the next element emitted from the upstream publisher.
  /// - Returns: A publisher that transforms elements by applying a closure that receives its previous return value and the next element from the upstream publisher.
  public func scan<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Self.Output) -> T) -> _Publishers.Scan<Self, T> {
    return .init(upstream: self, initialResult: initialResult, nextPartialResult: nextPartialResult)
  }
  /// Transforms elements from the upstream publisher by providing the current element to an error-throwing closure along with the last value returned by the closure.
  ///
  /// If the closure throws an error, the publisher fails with the error.
  /// - Parameters:
  ///   - initialResult: The previous result returned by the `nextPartialResult` closure.
  ///   - nextPartialResult: An error-throwing closure that takes as its arguments the previous value returned by the closure and the next element emitted from the upstream publisher.
  /// - Returns: A publisher that transforms elements by applying a closure that receives its previous return value and the next element from the upstream publisher.
  public func tryScan<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Self.Output) throws -> T) -> _Publishers.TryScan<Self, T> {
    return .init(upstream: self, initialResult: initialResult, nextPartialResult: nextPartialResult)
  }
}
extension _Publishers {
  public struct Scan<Upstream: _Publisher, Output>: _Publisher {
    public typealias Failure = Upstream.Failure
    public let upstream: Upstream
    public let initialResult: Output
    public let nextPartialResult: (Output, Upstream.Output) -> Output
    public init(upstream: Upstream, initialResult: Output, nextPartialResult: @escaping (Output, Upstream.Output) -> Output) {
      self.upstream = upstream
      self.initialResult = initialResult
      self.nextPartialResult = nextPartialResult
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.Scan(downstream: subscriber, initialResult: initialResult, nextPartialResult: nextPartialResult)
      upstream.subscribe(midstream)
    }
  }
  public struct TryScan<Upstream: _Publisher, Output>: _Publisher {
    public typealias Failure = Swift.Error
    public let upstream: Upstream
    public let initialResult: Output
    public let nextPartialResult: (Output, Upstream.Output) throws -> Output
    public init(upstream: Upstream, initialResult: Output, nextPartialResult: @escaping (Output, Upstream.Output) throws -> Output) {
      self.upstream = upstream
      self.initialResult = initialResult
      self.nextPartialResult = nextPartialResult
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.TryScan<Upstream.Output, Upstream.Failure, Downstream>(downstream: subscriber, initialResult: initialResult, nextPartialResult: nextPartialResult)
      upstream.subscribe(midstream)
    }
  }
}
private extension _Publishers.Channel {
  class ScanBase<UpstreamOutput, UpstreamFailure: Swift.Error, Downstream: _Subscriber>: _Publishers.Channel.TransformBase<UpstreamOutput, UpstreamFailure, Downstream> {
    let lock: Locking = Lock()
    var result: Downstream.Input?
    let nextPartialResult: (Downstream.Input, Input) throws -> Downstream.Input
    init(downstream: Downstream, initialResult: Downstream.Input, nextPartialResult: @escaping (Downstream.Input, Input) throws -> Downstream.Input) {
      self.result = initialResult
      self.nextPartialResult = nextPartialResult
      super.init(downstream: downstream)
    }
    override func transformInput(_ input: Input) throws -> Downstream.Input? {
      return try lock.withLock {
        let current = try self.nextPartialResult(result!, input)
        result = current
        return current
      }
    }
    override func willComplete(completion: _Subscribers.Completion<Failure>) {
      result = nil
    }
  }
  class Scan<UpstreamOutput, Downstream: _Subscriber>: ScanBase<UpstreamOutput, Downstream.Failure, Downstream> {
    override var description: String {
      return "Scan"
    }
  }
  class TryScan<UpstreamOutput, UpstreamFailure: Swift.Error, Downstream: _Subscriber>: ScanBase<UpstreamOutput, UpstreamFailure, Downstream> where Downstream.Failure == Error {
    override var description: String {
      return "TryScan"
    }
  }
}
