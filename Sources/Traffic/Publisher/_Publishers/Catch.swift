extension _Publisher {
  /// Handles errors from an upstream publisher by replacing it with another publisher.
  ///
  /// The following example replaces any error from the upstream publisher and replaces the upstream with a `Just` publisher. This continues the stream by publishing a single value and completing normally.
  /// ```
  /// enum SimpleError: Swift.Error { case error }
  /// let errorPublisher = (0..<10).publisher.tryMap { v -> Int in
  ///     if v < 5 {
  ///         return v
  ///     } else {
  ///         throw SimpleError.error
  ///     }
  /// }
  ///
  /// let noErrorPublisher = errorPublisher.catch { _ in
  ///     return Just(100)
  /// }
  /// ```
  /// Backpressure note: This publisher passes through `request` and `cancel` to the upstream. After receiving an error, the publisher sends sends any unfulfilled demand to the new `Publisher`.
  /// - Parameter handler: A closure that accepts the upstream failure as input and returns a publisher to replace the upstream publisher.
  /// - Returns: A publisher that handles errors from an upstream publisher by replacing the failed publisher with another publisher.
  public func `catch`<P: _Publisher>(_ handler: @escaping (Self.Failure) -> P) -> _Publishers.Catch<Self, P> where Self.Output == P.Output {
    return .init(upstream: self, handler: handler)
  }
  /// Handles errors from an upstream publisher by either replacing it with another publisher or `throw`ing  a new error.
  ///
  /// - Parameter handler: A `throw`ing closure that accepts the upstream failure as input and returns a publisher to replace the upstream publisher or if an error is thrown will send the error downstream.
  /// - Returns: A publisher that handles errors from an upstream publisher by replacing the failed publisher with another publisher.
  public func tryCatch<P: _Publisher>(_ handler: @escaping (Self.Failure) throws -> P) -> _Publishers.TryCatch<Self, P> where Self.Output == P.Output {
    return .init(upstream: self, handler: handler)
  }
}
extension _Publishers {
  /// A publisher that handles errors from an upstream publisher by replacing the failed publisher with another publisher.
  public struct Catch<Upstream: _Publisher, NewPublisher: _Publisher>: _Publisher where Upstream.Output == NewPublisher.Output {
    public typealias Output = Upstream.Output
    public typealias Failure = NewPublisher.Failure
    /// The publisher that this publisher receives elements from.
    public let upstream: Upstream
    /// A closure that accepts the upstream failure as input and returns a publisher to replace the upstream publisher.
    public let handler: (Upstream.Failure) -> NewPublisher
    /// Creates a publisher that handles errors from an upstream publisher by replacing the failed publisher with another publisher.
    ///
    /// - Parameters:
    ///   - upstream: The publisher that this publisher receives elements from.
    ///   - handler: A closure that accepts the upstream failure as input and returns a publisher to replace the upstream publisher.
    public init(upstream: Upstream, handler: @escaping (Upstream.Failure) -> NewPublisher) {
      self.upstream = upstream
      self.handler = handler
    }
    public func receive<S: _Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
      CatchWrapper(upstream: upstream, handler: handler).receive(label: "Catch", subscriber: subscriber)
    }
  }
  /// A publisher that handles errors from an upstream publisher by replacing the failed publisher with another publisher or optionally producing a new error.
  public struct TryCatch<Upstream: _Publisher, NewPublisher: _Publisher>: _Publisher where Upstream.Output == NewPublisher.Output {
    public typealias Output = Upstream.Output
    public typealias Failure = Swift.Error
    public let upstream: Upstream
    public let handler: (Upstream.Failure) throws -> NewPublisher
    public init(upstream: Upstream, handler: @escaping (Upstream.Failure) throws -> NewPublisher) {
      self.upstream = upstream
      self.handler = handler
    }
    public func receive<S: _Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
      CatchWrapper(upstream: upstream, handler: handler).receive(label: "TryCatch", subscriber: subscriber)
    }
  }
  private struct CatchWrapper<Upstream: _Publisher, NewPublisher: _Publisher> where Upstream.Output == NewPublisher.Output {
    public typealias Output = Upstream.Output
    public let upstream: Upstream
    public let handler: (Upstream.Failure) throws -> NewPublisher
    public init(upstream: Upstream, handler: @escaping (Upstream.Failure) throws -> NewPublisher) {
      self.upstream = upstream
      self.handler = handler
    }
    public func receive<Downstream: _Subscriber>(label: String, subscriber: Downstream) where Downstream.Input == Output {
      let midstream = Channel.Anonymous<Upstream.Output, Upstream.Failure, Downstream>(label: label, downstream: subscriber, receiveSubscription: { (channel, subscription) in
        channel.downstream.receive(subscription: subscription)
      }, receiveValue: { (channel, value) in
        return channel.downstream.receive(value)
      }, receiveCompletion: { (channel, completion) in
        switch completion {
        case let .failure(error):
            let newMidstream = Channel.Anonymous<NewPublisher.Output, NewPublisher.Failure, Downstream>(label: label, downstream: channel.downstream, receiveSubscription: { (channel, subscription) in
            subscription.request(.unlimited)
          }, receiveValue: { (channel, value) in
            return channel.downstream.receive(value)
          }, receiveCompletion: { (channel, completion) in
            channel.downstream.receive(completion: completion.mapError(transform: { (error) in error as! Downstream.Failure }))
          })
          do {
            (try self.handler(error)).subscribe(newMidstream)
          } catch {
            channel.downstream.receive(completion: .failure(error as! Downstream.Failure))
          }
        case .finished:
          channel.downstream.receive(completion: .finished)
        }
      })
      upstream.subscribe(midstream)
    }
  }
}
