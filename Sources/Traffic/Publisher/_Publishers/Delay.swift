extension _Publisher {
  /// Delays delivery of all output to the downstream receiver by a specified amount of time on a particular scheduler.
  ///
  /// The delay affects the delivery of elements and completion, but not of the original subscription.
  /// - Parameters:
  ///   - interval: The amount of time to delay.
  ///   - tolerance: The allowed tolerance in firing delayed events.
  ///   - scheduler: The scheduler to deliver the delayed events.
  /// - Returns: A publisher that delays delivery of elements and completion to the downstream receiver.
  public func delay<S: _Scheduler>(for interval: S.SchedulerTimeType.Stride, tolerance: S.SchedulerTimeType.Stride? = nil, scheduler: S, options: S.SchedulerOptions? = nil) -> _Publishers.Delay<Self, S> {
    return .init(upstream: self, interval: interval, tolerance: tolerance ?? scheduler.minimumTolerance, scheduler: scheduler, options: options)
  }
}
extension _Publishers {
  /// A publisher that delays delivery of elements and completion to the downstream receiver.
  public struct Delay<Upstream: _Publisher, Context: _Scheduler>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Upstream.Failure
    /// The publisher that this publisher receives elements from.
    public let upstream: Upstream
    /// The amount of time to delay.
    public let interval: Context.SchedulerTimeType.Stride
    /// The allowed tolerance in firing delayed events.
    public let tolerance: Context.SchedulerTimeType.Stride
    /// The scheduler to deliver the delayed events.
    public let scheduler: Context
    public let options: Context.SchedulerOptions?
    public init(upstream: Upstream, interval: Context.SchedulerTimeType.Stride, tolerance: Context.SchedulerTimeType.Stride, scheduler: Context, options: Context.SchedulerOptions? = nil) {
      self.upstream = upstream
      self.interval = interval
      self.tolerance = tolerance
      self.scheduler = scheduler
      self.options = options
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.Delay(downstream: subscriber, delay: self)
      upstream.subscribe(midstream)
    }
  }
}
private extension _Publishers.Channel {
  final class Delay<Context: _Scheduler, Downstream: _Subscriber>: Base<Downstream.Input, Downstream.Failure, Downstream> {
    let interval: Context.SchedulerTimeType.Stride
    let tolerance: Context.SchedulerTimeType.Stride
    let scheduler: Context
    let options: Context.SchedulerOptions?
    init<Upstream: _Publisher>(downstream: Downstream, delay: _Publishers.Delay<Upstream, Context>) where Upstream.Output == Downstream.Input, Upstream.Failure == Downstream.Failure {
      self.interval = delay.interval
      self.tolerance = delay.tolerance
      self.scheduler = delay.scheduler
      self.options = delay.options
      super.init(downstream: downstream)
    }
    override func receive(subscription: _Subscription) {
      guard shouldReceive(subscription: subscription) else {
        return
      }
      downstream.receive(subscription: self)
    }
    override func receive(_ input: Input) -> _Subscribers.Demand {
      guard isSubscribedAndNotCompleted() else {
        return .none
      }
      scheduler.schedule(after: scheduler.now.advanced(by: interval), tolerance: tolerance, options: options) {
        guard self.isSubscribed() else {
          return
        }
        _ = self.downstream.receive(input)
      }
      return .none
    }
    override func receive(completion: _Subscribers.Completion<Failure>) {
      guard shouldReceiveCompletion(completion) else {
        return
      }
      scheduler.schedule(after: scheduler.now.advanced(by: interval), tolerance: tolerance, options: options) {
        self.downstream.receive(completion: completion)
      }
    }
    override var description: String {
      return "Delay"
    }
  }
}
