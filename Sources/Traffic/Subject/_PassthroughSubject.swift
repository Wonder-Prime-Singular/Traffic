public final class _PassthroughSubject<Output, Failure: Swift.Error>: _Subject {
  var completion: _Subscribers.Completion<Failure>?
  var receiveValues: [CombineIdentifier: (Output) -> _Subscribers.Demand] = [:]
  var receiveCompletions: [CombineIdentifier: (_Subscribers.Completion<Failure>) -> Void] = [:]
  var upstreamSubscription: [_Subscription] = []
  internal let lock: Locking = RecursiveLock()
  public init() {}
  public func send(_ value: Output) {
    lock.withLock {
      receiveValues.forEach { (_, receiveValue) in
        _ = receiveValue(value)
      }
    }
  }
  public func send(completion: _Subscribers.Completion<Failure>) {
    lock.withLock {
      self.completion = completion
      receiveCompletions.forEach { (_, receiveCompletion) in
        receiveCompletion(completion)
      }
    }
  }
  public func send(subscription: _Subscription) {
    lock.withLock {
      upstreamSubscription.append(subscription)
      subscription.request(.unlimited)
    }
  }
  public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
    lock.withLock {
      if completion != nil {
        subscriber.receive(subscription: _Subscriptions.empty)
        subscriber.receive(completion: completion!)
      } else {
        let id = subscriber.combineIdentifier
        let leading = _Subscriptions.Leading.PassthroughSubject(publisher: self, downstream: subscriber)
        receiveValues[id] = { (value) in
          return subscriber.receive(value)
        }
        receiveCompletions[id] = { (completion) in
          subscriber.receive(completion: completion)
        }
        subscriber.receive(subscription: leading)
      }
    }
  }
}
private extension _Subscriptions.Leading {
  class PassthroughSubject<Downstream: _Subscriber>: _Subscriptions.Leading.Base<_PassthroughSubject<Downstream.Input, Downstream.Failure>, Downstream> {
    override func cancel() {
      guard let id = downstream?.combineIdentifier else {
        return
      }
      publisher.lock.withTryLock {
        self.publisher.receiveValues.removeValue(forKey: id)
        self.publisher.receiveCompletions.removeValue(forKey: id)
      }
      downstream = nil
    }
    override func request(_ demand: _Subscribers.Demand) {
    }
    override var description: String {
      return "PassthroughSubject"
    }
  }
}
