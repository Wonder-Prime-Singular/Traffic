extension _Publisher {
  /// Buffers elements received from an upstream publisher.
  /// - Parameter size: The maximum number of elements to store.
  /// - Parameter prefetch: The strategy for initially populating the buffer.
  /// - Parameter whenFull: The action to take when the buffer becomes full.
  public func buffer(size: Int, prefetch: _Publishers.PrefetchStrategy, whenFull: _Publishers.BufferingStrategy<Self.Failure>) -> _Publishers.Buffer<Self> {
    return .init(upstream: self, size: size, prefetch: prefetch, whenFull: whenFull)
  }
}
extension _Publishers {
  /// A strategy for filling a buffer.
  ///
  /// * keepFull: A strategy to fill the buffer at subscription time, and keep it full thereafter.
  /// * byRequest: A strategy that avoids prefetching and instead performs requests on demand.
  public enum PrefetchStrategy: Equatable, Hashable {
    case keepFull
    case byRequest
  }
  /// A strategy for handling exhaustion of a buffer’s capacity.
  ///
  /// * dropNewest: When full, discard the newly-received element without buffering it.
  /// * dropOldest: When full, remove the least recently-received element from the buffer.
  /// * customError: When full, execute the closure to provide a custom error.
  public enum BufferingStrategy<Failure: Swift.Error> {
    case dropNewest
    case dropOldest
    case customError(() -> Failure)
  }
  /// A publisher that buffers elements received from an upstream publisher.
  public struct Buffer<Upstream: _Publisher>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Upstream.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// The maximum number of elements to store.
    public let size: Int
    /// The strategy for initially populating the buffer.
    public let prefetch: PrefetchStrategy
    /// The action to take when the buffer becomes full.
    public let whenFull: BufferingStrategy<Upstream.Failure>
    /// Creates a publisher that buffers elements received from an upstream publisher.
    /// - Parameter upstream: The publisher from which this publisher receives elements.
    /// - Parameter size: The maximum number of elements to store.
    /// - Parameter prefetch: The strategy for initially populating the buffer.
    /// - Parameter whenFull: The action to take when the buffer becomes full.
    public init(upstream: Upstream, size: Int, prefetch: PrefetchStrategy, whenFull: BufferingStrategy<Failure>) {
      self.upstream = upstream
      self.size = size
      self.prefetch = prefetch
      self.whenFull = whenFull
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let lock = Lock()
      let size = self.size
      let prefetch = self.prefetch
      let whenFull = self.whenFull
      var outputs: [Upstream.Output] = []
      var prefetchSubscription: _Subscription?
      let midstream = Channel.Anonymous<Upstream.Output, Upstream.Failure, Downstream>(label: "Breakpoint", downstream: subscriber, receiveSubscription: { (channel, subscription) in
        lock.withLock {
          switch prefetch {
          case .keepFull:
            prefetchSubscription = subscription
          case .byRequest:
            channel.downstream.receive(subscription: subscription)
          }
        }
      }, receiveValue: { (channel, value) in
        lock.withLock {
          outputs.append(value)
          if outputs.count == size {
            switch whenFull {
            case .dropNewest:
              outputs.removeLast()
            case .dropOldest:
              outputs.removeFirst()
            case let .customError(make):
              channel.downstream.receive(completion: .failure(make()))
              return .none
            }
          }
          return outputs.reduce(_Subscribers.Demand.none, { (demand, output) in
            return demand + channel.downstream.receive(output)
          })
        }
      }, receiveCompletion: { (channel, completion) in
        lock.withLock {
          channel.downstream.receive(completion: completion)
          prefetchSubscription?.cancel()
        }
      })
      upstream.subscribe(midstream)
    }
  }
}
