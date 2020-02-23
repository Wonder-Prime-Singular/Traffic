extension _Publisher {
  /// Publishes elements only after a specified time interval elapses between events.
  ///
  /// Use this operator when you want to wait for a pause in the delivery of events from the upstream publisher. For example, call `debounce` on the publisher from a text field to only receive elements when the user pauses or stops typing. When they start typing again, the `debounce` holds event delivery until the next pause.
  /// - Parameters:
  ///   - dueTime: The time the publisher should wait before publishing an element.
  ///   - scheduler: The scheduler on which this publisher delivers elements
  ///   - options: Scheduler options that customize this publisher’s delivery of elements.
  /// - Returns: A publisher that publishes events only after a specified time elapses.
  public func debounce<S: _Scheduler>(for dueTime: S.SchedulerTimeType.Stride, scheduler: S, options: S.SchedulerOptions? = nil) -> _Publishers.Debounce<Self, S> {
    return .init(upstream: self, dueTime: dueTime, scheduler: scheduler, options: options)
  }
}
extension _Publishers {
  /// A publisher that publishes elements only after a specified time interval elapses between events.
  public struct Debounce<Upstream: _Publisher, Context: _Scheduler>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Upstream.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// The amount of time the publisher should wait before publishing an element.
    public let dueTime: Context.SchedulerTimeType.Stride
    /// The scheduler on which this publisher delivers elements.
    public let scheduler: Context
    /// Scheduler options that customize this publisher’s delivery of elements.
    public let options: Context.SchedulerOptions?
    public init(upstream: Upstream, dueTime: Context.SchedulerTimeType.Stride, scheduler: Context, options: Context.SchedulerOptions?) {
      self.upstream = upstream
      self.dueTime = dueTime
      self.scheduler = scheduler
      self.options = options
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let lock = Lock()
      let upstream = self.upstream
      let dueTime = self.dueTime
      let scheduler = self.scheduler
      let options = self.options
      var index: Int64 = 0
      let midstream = Channel.Anonymous<Upstream.Output, Upstream.Failure, Downstream>(label: "Debounce", downstream: subscriber, receiveSubscription: { (channel, subscription) in
        channel.downstream.receive(subscription: subscription)
      }, receiveValue: { (channel, value) in
        let currentIndex: Int64 = lock.withLock {
          index &+= 1
          return index
        }
        scheduler.schedule(after: scheduler.now.advanced(by: dueTime), tolerance: scheduler.minimumTolerance, options: options) {
          lock.withLock {
            guard channel.isSubscribedAndNotCompleted() else {
              return
            }
            guard index == currentIndex else {
              return
            }
            _ = channel.downstream.receive(value)
          }
        }
        return .unlimited
      }, receiveCompletion: { (channel, completion) in
        lock.withLock {
          guard channel.isSubscribedAndNotCompleted() else {
            return
          }
          channel.downstream.receive(completion: completion)
        }
      })
      upstream.subscribe(midstream)
    }
  }
}
