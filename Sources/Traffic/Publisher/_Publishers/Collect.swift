extension _Publisher {
  /// Collects all received elements, and emits a single array of the collection when the upstream publisher finishes.
  ///
  /// If the upstream publisher fails with an error, this publisher forwards the error to the downstream receiver instead of sending its output.
  /// This publisher requests an unlimited number of elements from the upstream publisher. It only sends the collected array to its downstream after a request whose demand is greater than 0 items.
  /// Note: This publisher uses an unbounded amount of memory to store the received values.
  ///
  /// - Returns: A publisher that collects all received items and returns them as an array upon completion.
  public func collect() -> _Publishers.Collect<Self> {
    return .init(upstream: self)
  }
  /// Collects up to the specified number of elements, and then emits a single array of the collection.
  ///
  /// If the upstream publisher finishes before filling the buffer, this publisher sends an array of all the items it has received. This may be fewer than `count` elements.
  /// If the upstream publisher fails with an error, this publisher forwards the error to the downstream receiver instead of sending its output.
  /// Note: When this publisher receives a request for `.max(n)` elements, it requests `.max(count * n)` from the upstream publisher.
  /// - Parameter count: The maximum number of received elements to buffer before publishing.
  /// - Returns: A publisher that collects up to the specified number of elements, and then publishes them as an array.
  public func collect(_ count: Int) -> _Publishers.CollectByCount<Self> {
    return .init(upstream: self, count: count)
  }
  /// Collects elements by a given strategy, and emits a single array of the collection.
  ///
  /// If the upstream publisher finishes before filling the buffer, this publisher sends an array of all the items it has received. This may be fewer than `count` elements.
  /// If the upstream publisher fails with an error, this publisher forwards the error to the downstream receiver instead of sending its output.
  /// Note: When this publisher receives a request for `.max(n)` elements, it requests `.max(count * n)` from the upstream publisher.
  /// - Parameters:
  ///   - strategy: The strategy with which to collect and publish elements.
  ///   - options: `Scheduler` options to use for the strategy.
  /// - Returns: A publisher that collects elements by a given strategy, and emits a single array of the collection.
  public func collect<S: _Scheduler>(_ strategy: _Publishers.TimeGroupingStrategy<S>, options: S.SchedulerOptions? = nil) -> _Publishers.CollectByTime<Self, S> {
    return .init(upstream: self, strategy: strategy, options: options)
  }
}
extension _Publishers {
  /// A strategy for collecting received elements.
  ///
  /// - byTime: Collect and periodically publish items.
  /// - byTimeOrCount: Collect and publish items, either periodically or when a buffer reaches its maximum size.
  public enum TimeGroupingStrategy<Context: _Scheduler> {
    case byTime(Context, Context.SchedulerTimeType.Stride)
    case byTimeOrCount(Context, Context.SchedulerTimeType.Stride, Int)
  }
  /// A publisher that buffers and periodically publishes its items.
  public struct CollectByTime<Upstream: _Publisher, Context: _Scheduler>: _Publisher {
    public typealias Output = [Upstream.Output]
    public typealias Failure = Upstream.Failure
    /// The publisher that this publisher receives elements from.
    public let upstream: Upstream
    /// The strategy with which to collect and publish elements.
    public let strategy: TimeGroupingStrategy<Context>
    /// `Scheduler` options to use for the strategy.
    public let options: Context.SchedulerOptions?
    public init(upstream: Upstream, strategy: TimeGroupingStrategy<Context>, options: Context.SchedulerOptions?) {
      self.upstream = upstream
      self.strategy = strategy
      self.options = options
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let lock = RecursiveLock()
      let strategy = self.strategy
      let options = self.options
      var outputs: [Upstream.Output] = []
      var cancel: _Cancellable?
      let midstream = Channel.Anonymous<Upstream.Output, Upstream.Failure, Downstream>(label: "CollectByTime", downstream: subscriber, receiveSubscription: { (channel, subscription) in
        lock.withLock {
          channel.downstream.receive(subscription: subscription)
          switch strategy {
          case let .byTime(context, interval):
            cancel = context.schedule(after: context.now, interval: interval, tolerance: context.minimumTolerance, options: options) {
              lock.withLock {
                let values = outputs
                outputs.removeAll()
                _ = channel.downstream.receive(values)
              }
            }
          case let .byTimeOrCount(context, interval, _):
            cancel = context.schedule(after: context.now, interval: interval, tolerance: context.minimumTolerance, options: options) {
              lock.withLock {
                let values = outputs
                outputs.removeAll()
                _ = channel.downstream.receive(values)
              }
            }
          }
        }
      }, receiveValue: { (channel, value) in
        lock.withLock {
          outputs.append(value)
          if case let .byTimeOrCount(_, _, count) = strategy, outputs.count == count {
            let values = outputs
            outputs.removeAll()
            return channel.downstream.receive(values)
          } else {
            return .unlimited
          }
        }
      }, receiveCompletion: { (channel, completion) in
        lock.withLock {
          channel.downstream.receive(completion: completion)
          cancel?.cancel()
        }
      })
      upstream.subscribe(midstream)
    }
  }
  /// A publisher that buffers items.
  public struct Collect<Upstream: _Publisher>: _Publisher {
    public typealias Output = [Upstream.Output]
    public typealias Failure = Upstream.Failure
    /// The publisher that this publisher receives elements from.
    public let upstream: Upstream
    public init(upstream: Upstream) {
      self.upstream = upstream
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let lock = Lock()
      var outputs: [Upstream.Output] = []
      let midstream = Channel.Anonymous<Upstream.Output, Upstream.Failure, Downstream>(label: "Collect", downstream: subscriber, receiveSubscription: { (channel, subscription) in
        lock.withLock {
          channel.downstream.receive(subscription: subscription)
        }
      }, receiveValue: { (channel, value) in
        lock.withLock {
          outputs.append(value)
          return channel.downstream.receive(outputs)
        }
      }, receiveCompletion: { (channel, completion) in
        lock.withLock {
          channel.downstream.receive(completion: completion)
        }
      })
      upstream.subscribe(midstream)
    }
  }
  /// A publisher that buffers a maximum number of items.
  public struct CollectByCount<Upstream: _Publisher>: _Publisher {
    public typealias Output = [Upstream.Output]
    public typealias Failure = Upstream.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    ///  The maximum number of received elements to buffer before publishing.
    public let count: Int
    public init(upstream: Upstream, count: Int) {
      self.upstream = upstream
      self.count = count
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let lock = Lock()
      let count = self.count
      var outputs: [Upstream.Output] = []
      let midstream = Channel.Anonymous<Upstream.Output, Upstream.Failure, Downstream>(label: "CollectByCount", downstream: subscriber, receiveSubscription: { (channel, subscription) in
        lock.withLock {
          channel.downstream.receive(subscription: subscription)
        }
      }, receiveValue: { (channel, value) in
        lock.withLock {
          outputs.append(value)
          if outputs.count == count {
            let values = outputs
            outputs.removeAll()
            return channel.downstream.receive(values)
          } else {
            return .unlimited
          }
        }
      }, receiveCompletion: { (channel, completion) in
        lock.withLock {
          channel.downstream.receive(completion: completion)
        }
      })
      upstream.subscribe(midstream)
    }
  }
}
extension _Publishers.Collect: Equatable where Upstream: Equatable {}
extension _Publishers.CollectByCount: Equatable where Upstream: Equatable {}
