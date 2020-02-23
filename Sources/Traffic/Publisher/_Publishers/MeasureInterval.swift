extension _Publisher {
  /// Measures and emits the time interval between events received from an upstream publisher.
  ///
  /// The output type of the returned scheduler is the time interval of the provided scheduler.
  /// - Parameters:
  ///   - scheduler: The scheduler on which to deliver elements.
  ///   - options: Options that customize the delivery of elements.
  /// - Returns: A publisher that emits elements representing the time interval between the elements it receives.
  public func measureInterval<S: _Scheduler>(using scheduler: S, options: S.SchedulerOptions? = nil) -> _Publishers.MeasureInterval<Self, S> {
    return .init(upstream: self, scheduler: scheduler)
  }
}
extension _Publishers {
  /// A publisher that measures and emits the time interval between events received from an upstream publisher.
  public struct MeasureInterval<Upstream: _Publisher, Context: _Scheduler>: _Publisher {
    public typealias Output = Context.SchedulerTimeType.Stride
    public typealias Failure = Upstream.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// The scheduler on which to deliver elements.
    public let scheduler: Context
    public init(upstream: Upstream, scheduler: Context) {
      self.upstream = upstream
      self.scheduler = scheduler
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      var now: Context.SchedulerTimeType?
      let midstream = Channel.Anonymous<Upstream.Output, Upstream.Failure, Downstream>(label: "MeasureInterval", downstream: subscriber, receiveSubscription: { (channel, subscription) in
        channel.downstream.receive(subscription: subscription)
      }, receiveValue: { (channel, value) in
        var demand: _Subscribers.Demand = .unlimited
        if let oldNow = now {
          let newNow = self.scheduler.now
          demand = channel.downstream.receive(newNow.distance(to: oldNow))
          now = newNow
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
