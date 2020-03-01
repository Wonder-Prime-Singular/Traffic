/// A subject that wraps a single value and publishes a new element whenever the value changes.
public final class _CurrentValueSubject<Output, Failure: Swift.Error>: _Subject {
  fileprivate var downstreams: [_Subscriptions.Leading.CurrentValueSubject<Output, Failure>] = []
  var completion: _Subscribers.Completion<Failure>?
  var upstreams: [_Subscription] = []
  var isUpstreamPublishingNeeded: Bool = false
  fileprivate var _value: Output
  let lock: Locking = RecursiveLock()
  /// The value wrapped by this subject, published as a new element whenever it changes.
  public var value: Output {
    get {
      return _value
    }
    set {
      send(newValue)
    }
  }
  /// Creates a current value subject with the given initial value.
  ///
  /// - Parameter value: The initial value to publish.
  public init(_ value: Output) {
    _value = value
  }
  public func send(_ value: Output) {
    lock.withLock {
      _value = value
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
      subscription.request(.unlimited)
    }
  }
  public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
    lock.withLock {
      if completion != nil {
        subscriber.receive(subscription: _Subscriptions.empty)
        subscriber.receive(completion: completion!)
      } else {
        let leading = _Subscriptions.Leading.CurrentValueSubject(subject: self, downstream: subscriber)
        self.downstreams.append(leading)
        subscriber.receive(subscription: leading)
      }
    }
  }
}
private extension _Subscriptions.Leading {
  class CurrentValueSubject<Output, Failure: Swift.Error>: _Subscriptions.Leading.Subject<_CurrentValueSubject<Output, Failure>> {
    override func cancel() {
      subject = nil
      downstream = nil
    }
    override func request(_ demand: _Subscribers.Demand) {
      self.demand += demand
      if let value = subject?.value {
        receive(value)
      }
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
      return "CurrentValueSubject"
    }
  }
}
