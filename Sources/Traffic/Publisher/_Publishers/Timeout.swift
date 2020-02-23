extension _Publisher {
  /// Terminates publishing if the upstream publisher exceeds the specified time interval without producing an element.
  ///
  /// - Parameters:
  ///   - interval: The maximum time interval the publisher can go without emitting an element, expressed in the time system of the scheduler.
  ///   - scheduler: The scheduler to deliver events on.
  ///   - options: Scheduler options that customize the delivery of elements.
  ///   - customError: A closure that executes if the publisher times out. The publisher sends the failure returned by this closure to the subscriber as the reason for termination.
  /// - Returns: A publisher that terminates if the specified interval elapses with no events received from the upstream publisher.
  public func timeout<S: _Scheduler>(_ interval: S.SchedulerTimeType.Stride, scheduler: S, options: S.SchedulerOptions? = nil, customError: (() -> Self.Failure)? = nil) -> _Publishers.Timeout<Self, S> {
    return .init(upstream: self, interval: interval, scheduler: scheduler, options: options, customError: customError)
  }
}
extension _Publishers {
  public struct Timeout<Upstream: _Publisher, Context: _Scheduler>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Upstream.Failure
    public let upstream: Upstream
    public let interval: Context.SchedulerTimeType.Stride
    public let scheduler: Context
    public let options: Context.SchedulerOptions?
    public let customError: (() -> Upstream.Failure)?
    public init(upstream: Upstream, interval: Context.SchedulerTimeType.Stride, scheduler: Context, options: Context.SchedulerOptions?, customError: (() -> Failure)?) {
      self.upstream = upstream
      self.interval = interval
      self.scheduler = scheduler
      self.options = options
      self.customError = customError
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      var cancel: _Cancellable?
      let midstream = Channel.Anonymous<Upstream.Output, Upstream.Failure, Downstream>(label: "Timeout", downstream: subscriber, receiveSubscription: { (channel, subscription) in
        channel.downstream.receive(subscription: subscription)
      }, receiveValue: { (channel, value) in
        cancel?.cancel()
        cancel = self.scheduler.schedule(after: self.scheduler.now.advanced(by: self.interval), interval: self.interval, tolerance: self.scheduler.minimumTolerance, options: self.options) {
          channel.downstream.receive(completion: self.customError.map({ (c) in .failure(c()) }) ?? .finished)
        }
        return .unlimited
      }, receiveCompletion: { (channel, completion) in
        channel.downstream.receive(completion: completion)
      })
      upstream.subscribe(midstream)
    }
  }
}
