extension _Publisher {
  /// Applies a closure that accumulates each element of a stream and publishes a final result upon completion.
  ///
  /// - Parameters:
  ///   - initialResult: The value the closure receives the first time it is called.
  ///   - nextPartialResult: A closure that takes the previously-accumulated value and the next element from the upstream publisher to produce a new value.
  /// - Returns: A publisher that applies the closure to all received elements and produces an accumulated value when the upstream publisher finishes.
  public func reduce<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Self.Output) -> T) -> _Publishers.Reduce<Self, T> {
    return .init(upstream: self, initial: initialResult, nextPartialResult: nextPartialResult)
  }
  /// Applies an error-throwing closure that accumulates each element of a stream and publishes a final result upon completion.
  ///
  /// If the closure throws an error, the publisher fails, passing the error to its subscriber.
  /// - Parameters:
  ///   - initialResult: The value the closure receives the first time it is called.
  ///   - nextPartialResult: An error-throwing closure that takes the previously-accumulated value and the next element from the upstream publisher to produce a new value.
  /// - Returns: A publisher that applies the closure to all received elements and produces an accumulated value when the upstream publisher finishes.
  public func tryReduce<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Self.Output) throws -> T) -> _Publishers.TryReduce<Self, T> {
    return .init(upstream: self, initial: initialResult, nextPartialResult: nextPartialResult)
  }
}
extension _Publishers {
  /// A publisher that applies a closure to all received elements and produces an accumulated value when the upstream publisher finishes.
  public struct Reduce<Upstream: _Publisher, Output>: _Publisher {
    public typealias Failure = Upstream.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// The initial value provided on the first invocation of the closure.
    public let initial: Output
    /// A closure that takes the previously-accumulated value and the next element from the upstream publisher to produce a new value.
    public let nextPartialResult: (Output, Upstream.Output) -> Output
    public init(upstream: Upstream, initial: Output, nextPartialResult: @escaping (Output, Upstream.Output) -> Output) {
      self.upstream = upstream
      self.initial = initial
      self.nextPartialResult = nextPartialResult
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.Reduce(downstream: subscriber, initial: initial, nextPartialResult: nextPartialResult)
      upstream.subscribe(midstream)
    }
  }
  /// A publisher that applies an error-throwing closure to all received elements and produces an accumulated value when the upstream publisher finishes.
  public struct TryReduce<Upstream: _Publisher, Output>: _Publisher {
    public typealias Failure = Swift.Error
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// The initial value provided on the first invocation of the closure.
    public let initial: Output
    /// An error-throwing closure that takes the previously-accumulated value and the next element from the upstream to produce a new value.
    ///
    /// If this closure throws an error, the publisher fails and passes the error to its subscriber.
    public let nextPartialResult: (Output, Upstream.Output) throws -> Output
    public init(upstream: Upstream, initial: Output, nextPartialResult: @escaping (Output, Upstream.Output) throws -> Output) {
      self.upstream = upstream
      self.initial = initial
      self.nextPartialResult = nextPartialResult
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.TryReduce<Upstream.Output, Upstream.Failure, Downstream>(downstream: subscriber, initial: initial, nextPartialResult: nextPartialResult)
      upstream.subscribe(midstream)
    }
  }
}
private extension _Publishers.Channel {
  class ReduceBase<UpstreamOutput, UpstreamFailure: Swift.Error, Downstream: _Subscriber>: _Publishers.Channel.TransformBase<UpstreamOutput, UpstreamFailure, Downstream> {
    let lock: Locking = Lock()
    var result: Downstream.Input
    let nextPartialResult: (Downstream.Input, Input) throws -> Downstream.Input
    init(downstream: Downstream, initial: Downstream.Input, nextPartialResult: @escaping (Downstream.Input, Input) throws -> Downstream.Input) {
      self.result = initial
      self.nextPartialResult = nextPartialResult
      super.init(downstream: downstream)
    }
    override func transformInput(_ input: Input) throws -> Downstream.Input? {
      return try lock.withLock {
        let current = try self.nextPartialResult(result, input)
        result = current
        return nil
      }
    }
    override func willComplete(completion: _Subscribers.Completion<Failure>) {
      _ = downstream.receive(result)
    }
  }
  class Reduce<UpstreamOutput, Downstream: _Subscriber>: ReduceBase<UpstreamOutput, Downstream.Failure, Downstream> {
    override var description: String {
      return "Reduce"
    }
  }
  class TryReduce<UpstreamOutput, UpstreamFailure: Swift.Error, Downstream: _Subscriber>: ReduceBase<UpstreamOutput, UpstreamFailure, Downstream> where Downstream.Failure == Error {
    override var description: String {
      return "TryReduce"
    }
  }
}
