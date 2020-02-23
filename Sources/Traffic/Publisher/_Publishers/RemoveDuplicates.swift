extension _Publisher where Self.Output: Equatable {
  /// Publishes only elements that don’t match the previous element.
  ///
  /// - Returns: A publisher that consumes — rather than publishes — duplicate elements.
  public func removeDuplicates() -> _Publishers.RemoveDuplicates<Self> {
    return self.removeDuplicates(by: ==)
  }
}
extension _Publisher {
  /// Publishes only elements that don’t match the previous element, as evaluated by a provided closure.
  /// - Parameter predicate: A closure to evaluate whether two elements are equivalent, for purposes of filtering. Return `true` from this closure to indicate that the second element is a duplicate of the first.
  public func removeDuplicates(by predicate: @escaping (Self.Output, Self.Output) -> Bool) -> _Publishers.RemoveDuplicates<Self> {
    return .init(upstream: self, predicate: predicate)
  }
  /// Publishes only elements that don’t match the previous element, as evaluated by a provided error-throwing closure.
  /// - Parameter predicate: A closure to evaluate whether two elements are equivalent, for purposes of filtering. Return `true` from this closure to indicate that the second element is a duplicate of the first. If this closure throws an error, the publisher terminates with the thrown error.
  public func tryRemoveDuplicates(by predicate: @escaping (Self.Output, Self.Output) throws -> Bool) -> _Publishers.TryRemoveDuplicates<Self> {
    return .init(upstream: self, predicate: predicate)
  }
}
extension _Publishers {
  /// A publisher that publishes only elements that don’t match the previous element.
  public struct RemoveDuplicates<Upstream: _Publisher>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Upstream.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// A closure to evaluate whether two elements are equivalent, for purposes of filtering.
    public let predicate: (Upstream.Output, Upstream.Output) -> Bool
    /// Creates a publisher that publishes only elements that don’t match the previous element, as evaluated by a provided closure.
    /// - Parameter upstream: The publisher from which this publisher receives elements.
    /// - Parameter predicate: A closure to evaluate whether two elements are equivalent, for purposes of filtering. Return `true` from this closure to indicate that the second element is a duplicate of the first.
    public init(upstream: Upstream, predicate: @escaping (Output, Output) -> Bool) {
      self.upstream = upstream
      self.predicate = predicate
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.RemoveDuplicates(downstream: subscriber, predicate: predicate)
      upstream.subscribe(midstream)
    }
  }
  /// A publisher that publishes only elements that don’t match the previous element, as evaluated by a provided error-throwing closure.
  public struct TryRemoveDuplicates<Upstream: _Publisher>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Swift.Error
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// An error-throwing closure to evaluate whether two elements are equivalent, for purposes of filtering.
    public let predicate: (Upstream.Output, Upstream.Output) throws -> Bool
    /// Creates a publisher that publishes only elements that don’t match the previous element, as evaluated by a provided error-throwing closure.
    /// - Parameter upstream: The publisher from which this publisher receives elements.
    /// - Parameter predicate: An error-throwing closure to evaluate whether two elements are equivalent, for purposes of filtering. Return `true` from this closure to indicate that the second element is a duplicate of the first. If this closure throws an error, the publisher terminates with the thrown error.
    public init(upstream: Upstream, predicate: @escaping (Output, Output) throws -> Bool) {
      self.upstream = upstream
      self.predicate = predicate
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.TryRemoveDuplicates<Upstream.Failure, Downstream>(downstream: subscriber, predicate: predicate)
      upstream.subscribe(midstream)
    }
  }
}
private extension _Publishers.Channel {
  class RemoveDuplicatesBase<UpstreamFailure: Swift.Error, Downstream: _Subscriber>: _Publishers.Channel.TransformBase<Downstream.Input, UpstreamFailure, Downstream> {
    let lock = Lock()
    var previous: Downstream.Input?
    var this: Downstream.Input?
    let predicate: (Downstream.Input, Downstream.Input) throws -> Bool
    init(downstream: Downstream, predicate: @escaping (Downstream.Input, Downstream.Input) throws -> Bool) {
      self.predicate = predicate
      super.init(downstream: downstream)
    }
    override func transformInput(_ input: Input) throws -> Downstream.Input? {
      return try lock.withLock {
        switch (previous, this) {
        case (.none, _):
          previous = input
          return input
        case (_, .none):
          this = input
          fallthrough
        default:
          defer {
            previous = this
            this = nil
          }
          if !(try self.predicate(previous!, this!)) {
            return input
          }
        }
        return nil
      }
    }
    override func willComplete(completion: _Subscribers.Completion<Failure>) {
      previous = nil
      this = nil
    }
  }
  class RemoveDuplicates<Downstream: _Subscriber>: RemoveDuplicatesBase<Downstream.Failure, Downstream> {
    override var description: String {
      return "RemoveDuplicates"
    }
  }
  class TryRemoveDuplicates<UpstreamFailure: Swift.Error, Downstream: _Subscriber>: RemoveDuplicatesBase<UpstreamFailure, Downstream> {
    override var description: String {
      return "TryRemoveDuplicates"
    }
  }
}
