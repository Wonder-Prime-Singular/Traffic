extension _Publisher {
  /// Replaces nil elements in the stream with the proviced element.
  ///
  /// - Parameter output: The element to use when replacing `nil`.
  /// - Returns: A publisher that replaces `nil` elements from the upstream publisher with the provided element.
  public func replaceNil<T>(with output: T) -> _Publishers.Map<Self, T> where Self.Output == T? {
    return .init(upstream: self, transform: { (value) in value ?? output })
  }
}
extension _Publisher {
  /// Replaces any errors in the stream with the provided element.
  ///
  /// If the upstream publisher fails with an error, this publisher emits the provided element, then finishes normally.
  /// - Parameter output: An element to emit when the upstream publisher fails.
  /// - Returns: A publisher that replaces an error from the upstream publisher with the provided output element.
  public func replaceError(with output: Self.Output) -> _Publishers.ReplaceError<Self> {
    return .init(upstream: self, output: output)
  }
  /// Replaces an empty stream with the provided element.
  ///
  /// If the upstream publisher finishes without producing any elements, this publisher emits the provided element, then finishes normally.
  /// - Parameter output: An element to emit when the upstream publisher finishes without emitting any elements.
  /// - Returns: A publisher that replaces an empty stream with the provided output element.
  public func replaceEmpty(with output: Self.Output) -> _Publishers.ReplaceEmpty<Self> {
    return .init(upstream: self, output: output)
  }
}
extension _Publishers {
  /// A publisher that replaces an empty stream with a provided element.
  public struct ReplaceEmpty<Upstream: _Publisher>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Upstream.Failure
    /// The element to deliver when the upstream publisher finishes without delivering any elements.
    public let output: Upstream.Output
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    public init(upstream: Upstream, output: Output) {
      self.upstream = upstream
      self.output = output
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.Anonymous<Upstream.Output, Upstream.Failure, Downstream>(label: "ReplaceEmpty", downstream: subscriber, receiveSubscription: { (channel, subscription) in
        channel.downstream.receive(subscription: subscription)
      }, receiveValue: { (channel, value) in
        return channel.downstream.receive(value)
      }, receiveCompletion: { (channel, completion) in
        if case .finished = completion {
          _ = channel.downstream.receive(self.output)
        }
        channel.downstream.receive(completion: completion)
      })
      upstream.subscribe(midstream)
    }
  }
  /// A publisher that replaces any errors in the stream with a provided element.
  public struct ReplaceError<Upstream: _Publisher>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Never
    /// The element with which to replace errors from the upstream publisher.
    public let output: Upstream.Output
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    public init(upstream: Upstream, output: Output) {
      self.upstream = upstream
      self.output = output
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.Anonymous<Upstream.Output, Upstream.Failure, Downstream>(label: "ReplaceError", downstream: subscriber, receiveSubscription: { (channel, subscription) in
        channel.downstream.receive(subscription: subscription)
      }, receiveValue: { (channel, value) in
        return channel.downstream.receive(value)
      }, receiveCompletion: { (channel, completion) in
        switch completion {
        case .failure:
          _ = channel.downstream.receive(self.output)
        case .finished:
          channel.downstream.receive(completion: .finished)
        }
      })
      upstream.subscribe(midstream)
    }
  }
}
extension _Publishers.ReplaceEmpty: Equatable where Upstream: Equatable, Upstream.Output: Equatable {}
extension _Publishers.ReplaceError: Equatable where Upstream: Equatable, Upstream.Output: Equatable {}
