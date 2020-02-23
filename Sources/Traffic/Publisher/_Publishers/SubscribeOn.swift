extension _Publisher {
  /// Specifies the scheduler on which to perform subscribe, cancel, and request operations.
  ///
  /// In contrast with `receive(on:options:)`, which affects downstream messages, `subscribe(on:)` changes the execution context of upstream messages. In the following example, requests to `jsonPublisher` are performed on `backgroundQueue`, but elements received from it are performed on `RunLoop.main`.
  ///
  ///     let ioPerformingPublisher == // Some publisher.
  ///     let uiUpdatingSubscriber == // Some subscriber that updates the UI.
  ///
  ///     ioPerformingPublisher
  ///         .subscribe(on: backgroundQueue)
  ///         .receiveOn(on: RunLoop.main)
  ///         .subscribe(uiUpdatingSubscriber)
  ///
  /// - Parameters:
  ///   - scheduler: The scheduler on which to receive upstream messages.
  ///   - options: Options that customize the delivery of elements.
  /// - Returns: A publisher which performs upstream operations on the specified scheduler.
  public func subscribe<S: _Scheduler>(on scheduler: S, options: S.SchedulerOptions? = nil) -> _Publishers.SubscribeOn<Self, S> {
    return .init(upstream: self, scheduler: scheduler, options: options)
  }
}
extension _Publishers {
  /// A publisher that receives elements from an upstream publisher on a specific scheduler.
  public struct SubscribeOn<Upstream: _Publisher, Context: _Scheduler>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Upstream.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// The scheduler the publisher should use to receive elements.
    public let scheduler: Context
    /// Scheduler options that customize the delivery of elements.
    public let options: Context.SchedulerOptions?
    public init(upstream: Upstream, scheduler: Context, options: Context.SchedulerOptions?) {
      self.upstream = upstream
      self.scheduler = scheduler
      self.options = options
    }
    public func receive<S: _Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
      scheduler.schedule(options: options) {
        self.upstream.subscribe(subscriber)
      }
    }
  }
}
