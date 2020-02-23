extension _Publisher {
  /// Republishes elements while a predicate closure indicates publishing should continue.
  ///
  /// The publisher finishes when the closure returns `false`.
  ///
  /// - Parameter predicate: A closure that takes an element as its parameter and returns a Boolean value indicating whether publishing should continue.
  /// - Returns: A publisher that passes through elements until the predicate indicates publishing should finish.
  public func prefix(while predicate: @escaping (Self.Output) -> Bool) -> _Publishers.PrefixWhile<Self> {
    return .init(upstream: self, predicate: predicate)
  }
  /// Republishes elements while a error-throwing predicate closure indicates publishing should continue.
  ///
  /// The publisher finishes when the closure returns `false`. If the closure throws, the publisher fails with the thrown error.
  ///
  /// - Parameter predicate: A closure that takes an element as its parameter and returns a Boolean value indicating whether publishing should continue.
  /// - Returns: A publisher that passes through elements until the predicate throws or indicates publishing should finish.
  public func tryPrefix(while predicate: @escaping (Self.Output) throws -> Bool) -> _Publishers.TryPrefixWhile<Self> {
    return .init(upstream: self, predicate: predicate)
  }
}
extension _Publishers {
  /// A publisher that republishes elements while a predicate closure indicates publishing should continue.
  public struct PrefixWhile<Upstream: _Publisher>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Upstream.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// The closure that determines whether whether publishing should continue.
    public let predicate: (Upstream.Output) -> Bool
    public init(upstream: Upstream, predicate: @escaping (Output) -> Bool) {
      self.upstream = upstream
      self.predicate = predicate
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.PrefixWhile(downstream: subscriber, predicate: predicate)
      upstream.subscribe(midstream)
    }
  }
  /// A publisher that republishes elements while an error-throwing predicate closure indicates publishing should continue.
  public struct TryPrefixWhile<Upstream: _Publisher>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Swift.Error
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// The error-throwing closure that determines whether publishing should continue.
    public let predicate: (Upstream.Output) throws -> Bool
    public init(upstream: Upstream, predicate: @escaping (Output) throws -> Bool) {
      self.upstream = upstream
      self.predicate = predicate
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.TryPrefixWhile<Upstream.Failure, Downstream>(downstream: subscriber, predicate: predicate)
      upstream.subscribe(midstream)
    }
  }
}
private extension _Publishers.Channel {
  class PrefixWhileBase<UpstreamFailure: Swift.Error, Downstream: _Subscriber>: _Publishers.Channel.TransformBase<Downstream.Input, UpstreamFailure, Downstream> {
    let predicate: (Downstream.Input) throws -> Bool
    init(downstream: Downstream, predicate: @escaping (Downstream.Input) throws -> Bool) {
      self.predicate = predicate
      super.init(downstream: downstream)
    }
    override func transformInput(_ input: Input) throws -> Downstream.Input? {
      if try predicate(input) {
        return input
      } else {
        receive(completion: .finished)
        return nil
      }
    }
  }
  class PrefixWhile<Downstream: _Subscriber>: PrefixWhileBase<Downstream.Failure, Downstream> {
    override var description: String {
      return "PrefixWhile"
    }
  }
  class TryPrefixWhile<UpstreamFailure: Swift.Error, Downstream: _Subscriber>: PrefixWhileBase<UpstreamFailure, Downstream> where Downstream.Failure == Swift.Error {
    override var description: String {
      return "TryPrefixWhile"
    }
  }
}
