extension _Publisher {
  /// Attempts to recreate a failed subscription with the upstream publisher using a specified number of attempts to establish the connection.
  ///
  /// After exceeding the specified number of retries, the publisher passes the failure to the downstream receiver.
  /// - Parameter retries: The number of times to attempt to recreate the subscription.
  /// - Returns: A publisher that attempts to recreate its subscription to a failed upstream publisher.
  public func retry(_ retries: Int) -> _Publishers.Retry<Self> {
    return .init(upstream: self, retries: retries)
  }
}
extension _Publishers {
  /// A publisher that attempts to recreate its subscription to a failed upstream publisher.
  public struct Retry<Upstream: _Publisher>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Upstream.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// The maximum number of retry attempts to perform.
    ///
    /// If `nil`, this publisher attempts to reconnect with the upstream publisher an unlimited number of times.
    public let retries: Int?
    /// Creates a publisher that attempts to recreate its subscription to a failed upstream publisher.
    ///
    /// - Parameters:
    ///   - upstream: The publisher from which this publisher receives its elements.
    ///   - retries: The maximum number of retry attempts to perform. If `nil`, this publisher attempts to reconnect with the upstream publisher an unlimited number of times.
    public init(upstream: Upstream, retries: Int?) {
      self.upstream = upstream
      self.retries = retries
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      var count: Int = 0
      let midstream = Channel.Anonymous<Upstream.Output, Upstream.Failure, Downstream>(label: "Retry", downstream: subscriber, receiveSubscription: { (channel, subscription) in
        channel.downstream.receive(subscription: subscription)
      }, receiveValue: { (channel, value) in
        return channel.downstream.receive(value)
      }, receiveCompletion: { (channel, completion) in
        switch completion {
        case .finished:
          channel.downstream.receive(completion: completion)
        case .failure:
          if self.retries == nil || self.retries! > count {
            count += 1
            Retry<Upstream>(upstream: self.upstream, retries: self.retries.map({ (t) in t - 1 })).subscribe(subscriber)
          } else {
            channel.downstream.receive(completion: completion)
          }
        }
      })
      upstream.subscribe(midstream)
    }
  }
}
extension _Publishers.Retry: Equatable where Upstream: Equatable {}
