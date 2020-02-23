/// A subject that wraps a single value and publishes a new element whenever the value changes.
public final class _CurrentValueSubject<Output, Failure: Swift.Error>: _Subject {
  private var completion: _Subscribers.Completion<Failure>?
  fileprivate var receiveValues: [CombineIdentifier: (Output) -> _Subscribers.Demand] = [:]
  fileprivate var receiveCompletions: [CombineIdentifier: (_Subscribers.Completion<Failure>) -> Void] = [:]
  fileprivate var _value: Output
  fileprivate let lock: Locking = RecursiveLock()
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
      guard completion == nil else {
        return
      }
      _value = value
      receiveValues.forEach { (_, receiveValue) in
        _ = receiveValue(value)
      }
    }
  }
  public func send(completion: _Subscribers.Completion<Failure>) {
    lock.withLock {
      if self.completion == nil {
        self.completion = completion
      }
      receiveCompletions.forEach { (_, receiveCompletion) in
        receiveCompletion(completion)
      }
    }
  }
  public func send(subscription: _Subscription) {
    lock.withLock {
      guard completion == nil else {
        return
      }
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
        let leading = _Subscriptions.Leading.CurrentValueSubject(publisher: self, downstream: subscriber)
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
  class CurrentValueSubject<Downstream: _Subscriber>: _Subscriptions.Leading.Base<_CurrentValueSubject<Downstream.Input, Downstream.Failure>, Downstream> {
    override func cancel() {
      guard let id = downstream?.combineIdentifier else {
        return
      }
      publisher.lock.withLock {
        self.publisher.receiveValues.removeValue(forKey: id)
        self.publisher.receiveCompletions.removeValue(forKey: id)
      }
      downstream = nil
    }
    override func request(_ demand: _Subscribers.Demand) {
      if demand > .none {
        publisher.lock.withLock {
          _ = downstream?.receive(publisher.value)
        }
      }
    }
    override var description: String {
      return "CurrentValueSubject"
    }
  }
}
