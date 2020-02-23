extension _Publisher {
  /// Publishes either the most-recent or first element published by the upstream publisher in the specified time interval.
  ///
  /// - Parameters:
  ///   - interval: The interval at which to find and emit the most recent element, expressed in the time system of the scheduler.
  ///   - scheduler: The scheduler on which to publish elements.
  ///   - latest: A Boolean value that indicates whether to publish the most recent element. If `false`, the publisher emits the first element received during the interval.
  /// - Returns: A publisher that emits either the most-recent or first element received during the specified interval.
  public func throttle<S: _Scheduler>(for interval: S.SchedulerTimeType.Stride, scheduler: S, latest: Bool) -> _Publishers.Throttle<Self, S> {
    return .init(upstream: self, interval: interval, scheduler: scheduler, latest: latest)
  }
}
extension _Publishers {
  /// A publisher that publishes either the most-recent or first element published by the upstream publisher in a specified time interval.
  public struct Throttle<Upstream: _Publisher, Context: _Scheduler>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Upstream.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// The interval in which to find and emit the most recent element.
    public let interval: Context.SchedulerTimeType.Stride
    /// The scheduler on which to publish elements.
    public let scheduler: Context
    /// A Boolean value indicating whether to publish the most recent element.
    ///
    /// If `false`, the publisher emits the first element received during the interval.
    public let latest: Bool
    public init(upstream: Upstream, interval: Context.SchedulerTimeType.Stride, scheduler: Context, latest: Bool) {
      self.upstream = upstream
      self.interval = interval
      self.scheduler = scheduler
      self.latest = latest
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      var now: Context.SchedulerTimeType?
      var first: Upstream.Output?
      var last: Upstream.Output?
      let midstream = Channel.Anonymous<Upstream.Output, Upstream.Failure, Downstream>(label: "Throttle", downstream: subscriber, receiveSubscription: { (channel, subscription) in
        channel.downstream.receive(subscription: subscription)
      }, receiveValue: { (channel, value) in
        var demand: _Subscribers.Demand = .unlimited
        if first == nil {
          first = value
        }
        last = value
        if let oldNow = now {
          let newNow = self.scheduler.now
          if newNow.distance(to: oldNow) >= self.interval {
            let output = self.latest ? last : first
            demand = output.map(channel.downstream.receive(_:)) ?? .unlimited
            first = nil
            last = nil
            now = newNow
          }
        } else {
          now = self.scheduler.now
        }
        return demand
      }, receiveCompletion: { (channel, completion) in
        channel.downstream.receive(completion: completion)
      })
      upstream.subscribe(midstream)
    }
  }
}
