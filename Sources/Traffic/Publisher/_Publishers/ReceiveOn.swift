extension _Publisher {
  /// Specifies the scheduler on which to receive elements from the publisher.
  ///
  /// You use the `receive(on:options:)` operator to receive results on a specific scheduler, such as performing UI work on the main run loop.
  /// In contrast with `subscribe(on:options:)`, which affects upstream messages, `receive(on:options:)` changes the execution context of downstream messages. In the following example, requests to `jsonPublisher` are performed on `backgroundQueue`, but elements received from it are performed on `RunLoop.main`.
  ///
  ///     let jsonPublisher = MyJSONLoaderPublisher() // Some publisher.
  ///     let labelUpdater = MyLabelUpdateSubscriber() // Some subscriber that updates the UI.
  ///
  ///     jsonPublisher
  ///         .subscribe(on: backgroundQueue)
  ///         .receiveOn(on: RunLoop.main)
  ///         .subscribe(labelUpdater)
  ///
  /// - Parameters:
  ///   - scheduler: The scheduler the publisher is to use for element delivery.
  ///   - options: Scheduler options that customize the element delivery.
  /// - Returns: A publisher that delivers elements using the specified scheduler.
  public func receive<S: _Scheduler>(on scheduler: S, options: S.SchedulerOptions? = nil) -> _Publishers.ReceiveOn<Self, S> {
    return .init(upstream: self, scheduler: scheduler, options: options)
  }
}
extension _Publishers {
  /// A publisher that delivers elements to its downstream subscriber on a specific scheduler.
  public struct ReceiveOn<Upstream: _Publisher, Context: _Scheduler>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Upstream.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// The scheduler the publisher is to use for element delivery.
    public let scheduler: Context
    /// Scheduler options that customize the delivery of elements.
    public let options: Context.SchedulerOptions?
    public init(upstream: Upstream, scheduler: Context, options: Context.SchedulerOptions?) {
      self.upstream = upstream
      self.scheduler = scheduler
      self.options = options
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.ReceiveOn<Context, Downstream>(receiveOn: self, downstream: subscriber)
      upstream.subscribe(midstream)
    }
  }
}
private extension _Publishers.Channel {
  class ReceiveOn<Context: _Scheduler, Downstream: _Subscriber>: _Publishers.Channel.Base<Downstream.Input, Downstream.Failure, Downstream> {
    let lock: Locking = RecursiveLock()
    let scheduler: Context
    let options: Context.SchedulerOptions?
    init<Upstream: _Publisher>(receiveOn: _Publishers.ReceiveOn<Upstream, Context>, downstream: Downstream) where Upstream.Output == Downstream.Input, Upstream.Failure == Downstream.Failure {
      self.scheduler = receiveOn.scheduler
      self.options = receiveOn.options
      super.init(downstream: downstream)
    }
    override func receive(subscription: _Subscription) {
      guard super.shouldReceive(subscription: subscription) else {
        return
      }
      lock.withLock {
        downstream.receive(subscription: self)
      }
    }
    override func receive(_ input: Input) -> _Subscribers.Demand {
      guard super.isSubscribedAndNotCompleted() else {
        return .none
      }
      scheduler.schedule(options: options) { [weak self] in
        guard let self = self else {
          return
        }
        self.lock.withLock {
          guard !self.isCancelled() else {
            return
          }
          _ = self.downstream.receive(input)
        }
      }
      return .none
    }
    override func receive(completion: _Subscribers.Completion<Failure>) {
      guard super.shouldReceiveCompletion(completion) else {
        return
      }
      scheduler.schedule(options: options) { [weak self] in
        guard let self = self else {
          return
        }
        self.lock.withLock {
          guard !self.isCancelled() else {
            return
          }
          self.downstream.receive(completion: completion)
        }
      }
    }
    override var description: String {
      return "ReceiveOn"
    }
  }
}
