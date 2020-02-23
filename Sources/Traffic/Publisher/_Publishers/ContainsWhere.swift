extension _Publisher {
  /// Publishes a Boolean value upon receiving an element that satisfies the predicate closure.
  ///
  /// This operator consumes elements produced from the upstream publisher until the upstream publisher produces a matching element.
  /// - Parameter predicate: A closure that takes an element as its parameter and returns a Boolean value indicating whether the element satisfies the closure’s comparison logic.
  /// - Returns: A publisher that emits the Boolean value `true` when the upstream  publisher emits a matching value.
  public func contains(where predicate: @escaping (Self.Output) -> Bool) -> _Publishers.ContainsWhere<Self> {
    return .init(upstream: self, predicate: predicate)
  }
  /// Publishes a Boolean value upon receiving an element that satisfies the throwing predicate closure.
  ///
  /// This operator consumes elements produced from the upstream publisher until the upstream publisher produces a matching element. If the closure throws, the stream fails with an error.
  /// - Parameter predicate: A closure that takes an element as its parameter and returns a Boolean value indicating whether the element satisfies the closure’s comparison logic.
  /// - Returns: A publisher that emits the Boolean value `true` when the upstream publisher emits a matching value.
  public func tryContains(where predicate: @escaping (Self.Output) throws -> Bool) -> _Publishers.TryContainsWhere<Self> {
    return .init(upstream: self, predicate: predicate)
  }
}
extension _Publishers {
  /// A publisher that emits a Boolean value upon receiving an element that satisfies the predicate closure.
  public struct ContainsWhere<Upstream: _Publisher>: _Publisher {
    public typealias Output = Bool
    public typealias Failure = Upstream.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// The closure that determines whether the publisher should consider an element as a match.
    public let predicate: (Upstream.Output) -> Bool
    public init(upstream: Upstream, predicate: @escaping (Upstream.Output) -> Bool) {
      self.upstream = upstream
      self.predicate = predicate
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.ContainsWhere(downstream: subscriber, predicate: predicate)
      upstream.subscribe(midstream)
    }
  }
  /// A publisher that emits a Boolean value upon receiving an element that satisfies the throwing predicate closure.
  public struct TryContainsWhere<Upstream: _Publisher>: _Publisher {
    public typealias Output = Bool
    public typealias Failure = Swift.Error
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// The error-throwing closure that determines whether this publisher should emit a `true` element.
    public let predicate: (Upstream.Output) throws -> Bool
    public init(upstream: Upstream, predicate: @escaping (Upstream.Output) throws -> Bool) {
      self.upstream = upstream
      self.predicate = predicate
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.TryContainsWhere<Upstream.Output, Upstream.Failure, Downstream>(downstream: subscriber, predicate: predicate)
      upstream.subscribe(midstream)
    }
  }
}
private extension _Publishers.Channel {
  class ContainsWhereBase<UpstreamOutput, UpstreamFailure: Swift.Error, Downstream: _Subscriber>: TransformBase<UpstreamOutput, UpstreamFailure, Downstream> where Downstream.Input == Bool {
    var contains: Bool = false
    let predicate: (UpstreamOutput) throws -> Bool
    init(downstream: Downstream, predicate: @escaping (UpstreamOutput) throws -> Bool) {
      self.predicate = predicate
      super.init(downstream: downstream)
    }
    override func transformInput(_ input: Input) throws -> Downstream.Input? {
      if !contains, try predicate(input) {
        contains = true
        return true
      }
      return nil
    }
  }
  class ContainsWhere<UpstreamOutput, Downstream: _Subscriber>: ContainsWhereBase<UpstreamOutput, Downstream.Failure, Downstream> where Downstream.Input == Bool {
    override var description: String {
      return "ContainsWhere"
    }
  }
  class TryContainsWhere<UpstreamOutput, UpstreamFailure: Swift.Error, Downstream: _Subscriber>: ContainsWhereBase<UpstreamOutput, UpstreamFailure, Downstream> where Downstream.Input == Bool {
    override var description: String {
      return "TryContainsWhere"
    }
  }
}
