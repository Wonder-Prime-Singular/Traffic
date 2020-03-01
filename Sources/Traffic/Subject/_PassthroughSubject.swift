public final class _PassthroughSubject<Output, Failure: Swift.Error>: _Subject {
  fileprivate var downstreams: [_Subscriptions.Leading.PassthroughSubject<Output, Failure>] = []
  var completion: _Subscribers.Completion<Failure>?
  var upstreams: [_Subscription] = []
  var isUpstreamPublishingNeeded: Bool = false
  internal let lock: Locking = RecursiveLock()
  public init() {}
  public func send(_ value: Output) {
    lock.withLock {
      for downstream in downstreams where downstream.subject != nil && downstream.demand > 0 {
        downstream.receive(value)
      }
    }
  }
  public func send(completion: _Subscribers.Completion<Failure>) {
    lock.withLock {
      self.completion = completion
      for downstream in downstreams {
        downstream.receive(completion: completion)
      }
    }
  }
  public func send(subscription: _Subscription) {
    lock.withLock {
      upstreams.append(subscription)
      if isUpstreamPublishingNeeded {
        subscription.request(.unlimited)
      }
    }
  }
  func requestUpstreamToPublishIfNeeded() -> Void {
    guard !isUpstreamPublishingNeeded else {
      return
    }
    isUpstreamPublishingNeeded = true
    for s in upstreams {
      s.request(.unlimited)
    }
  }
  public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
    lock.withLock {
      if completion != nil {
        subscriber.receive(subscription: _Subscriptions.empty)
        subscriber.receive(completion: completion!)
      } else {
        let leading = _Subscriptions.Leading.PassthroughSubject(subject: self, downstream: subscriber)
        self.downstreams.append(leading)
        subscriber.receive(subscription: leading)
      }
    }
  }
}
private extension _Subscriptions.Leading {
  class PassthroughSubject<Output, Failure: Swift.Error>: _Subscriptions.Leading.Subject<_PassthroughSubject<Output, Failure>> {
    override func cancel() {
      subject = nil
      downstream = nil
    }
    override func request(_ demand: _Subscribers.Demand) {
      self.demand += demand
      self.subject?.requestUpstreamToPublishIfNeeded()
    }
    override func receive(_ input: Output) {
      demand += downstream?.receive(input) ?? 0
      demand -= 1
    }
    override func receive(completion: _Subscribers.Completion<Failure>) {
      subject = nil
      downstream?.receive(completion: completion)
      downstream = nil
    }
    override var description: String {
      return "PassthroughSubject"
    }
  }
}
