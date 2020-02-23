extension _Publisher {
  /// Publishes a single Boolean value that indicates whether all received elements pass a given predicate.
  ///
  /// When this publisher receives an element, it runs the predicate against the element. If the predicate returns `false`, the publisher produces a `false` value and finishes. If the upstream publisher finishes normally, this publisher produces a `true` value and finishes.
  /// As a `reduce`-style operator, this publisher produces at most one value.
  /// Backpressure note: Upon receiving any request greater than zero, this publisher requests unlimited elements from the upstream publisher.
  /// - Parameter predicate: A closure that evaluates each received element. Return `true` to continue, or `false` to cancel the upstream and complete.
  /// - Returns: A publisher that publishes a Boolean value that indicates whether all received elements pass a given predicate.
  public func allSatisfy(_ predicate: @escaping (Self.Output) -> Bool) -> _Publishers.AllSatisfy<Self> {
    return .init(upstream: self, predicate: predicate)
  }
  /// Publishes a single Boolean value that indicates whether all received elements pass a given error-throwing predicate.
  ///
  /// When this publisher receives an element, it runs the predicate against the element. If the predicate returns `false`, the publisher produces a `false` value and finishes. If the upstream publisher finishes normally, this publisher produces a `true` value and finishes. If the predicate throws an error, the publisher fails, passing the error to its downstream.
  /// As a `reduce`-style operator, this publisher produces at most one value.
  /// Backpressure note: Upon receiving any request greater than zero, this publisher requests unlimited elements from the upstream publisher.
  /// - Parameter predicate:  A closure that evaluates each received element. Return `true` to continue, or `false` to cancel the upstream and complete. The closure may throw, in which case the publisher cancels the upstream publisher and fails with the thrown error.
  /// - Returns:  A publisher that publishes a Boolean value that indicates whether all received elements pass a given predicate.
  public func tryAllSatisfy(_ predicate: @escaping (Self.Output) throws -> Bool) -> _Publishers.TryAllSatisfy<Self> {
    return .init(upstream: self, predicate: predicate)
  }
}
extension _Publishers {
  /// A publisher that publishes a single Boolean value that indicates whether all received elements pass a given predicate.
  public struct AllSatisfy<Upstream: _Publisher>: _Publisher {
    public typealias Output = Bool
    public typealias Failure = Upstream.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// A closure that evaluates each received element.
    ///
    ///  Return `true` to continue, or `false` to cancel the upstream and finish.
    public let predicate: (Upstream.Output) -> Bool
    public init(upstream: Upstream, predicate: @escaping (Upstream.Output) -> Bool) {
      self.upstream = upstream
      self.predicate = predicate
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.AllSatisfy(downstream: subscriber, predicate: predicate)
      upstream.subscribe(midstream)
    }
  }
  /// A publisher that publishes a single Boolean value that indicates whether all received elements pass a given error-throwing predicate.
  public struct TryAllSatisfy<Upstream: _Publisher>: _Publisher {
    public typealias Output = Bool
    public typealias Failure = Swift.Error
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// A closure that evaluates each received element.
    ///
    /// Return `true` to continue, or `false` to cancel the upstream and complete. The closure may throw, in which case the publisher cancels the upstream publisher and fails with the thrown error.
    public let predicate: (Upstream.Output) throws -> Bool
    public init(upstream: Upstream, predicate: @escaping (Upstream.Output) throws -> Bool) {
      self.upstream = upstream
      self.predicate = predicate
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.TryAllSatisfy<Upstream.Output, Upstream.Failure, Downstream>(downstream: subscriber, predicate: predicate)
      upstream.subscribe(midstream)
    }
  }
}
private extension _Publishers.Channel {
  class AllSatisfyBase<UpstreamOutput, UpstreamFailure: Swift.Error, Downstream: _Subscriber>: _Publishers.Channel.TransformBase<UpstreamOutput, UpstreamFailure, Downstream> where Downstream.Input == Bool {
    var allSatisfy: Bool?
    let predicate: (Input) throws -> Bool
    init(downstream: Downstream, predicate: @escaping (Input) throws -> Bool) {
      self.predicate = predicate
      super.init(downstream: downstream)
    }
    override func transformInput(_ input: Input) throws -> Downstream.Input? {
      guard allSatisfy == nil || allSatisfy! else {
        return nil
      }
      if try predicate(input) {
        allSatisfy = true
        return nil
      }
      allSatisfy = false
      return nil
    }
    override func willComplete(completion: _Subscribers.Completion<Failure>) {
      _ = downstream.receive(allSatisfy ?? true)
    }
  }
  class AllSatisfy<UpstreamOutput, Downstream: _Subscriber>: AllSatisfyBase<UpstreamOutput, Downstream.Failure, Downstream> where Downstream.Input == Bool {
    override var description: String {
      return "AllSatisfy"
    }
  }
  class TryAllSatisfy<UpstreamOutput, UpstreamFailure: Swift.Error, Downstream: _Subscriber>: AllSatisfyBase<UpstreamOutput, UpstreamFailure, Downstream> where Downstream.Input == Bool {
    override var description: String {
      return "TryAllSatisfy"
    }
  }
}
