/// A publisher that eventually produces one value and then finishes or fails.
public final class _Future<Output, Failure: Swift.Error>: _Publisher {
  public typealias Promise = (Swift.Result<Output, Failure>) -> Void
  fileprivate var result: Result<Output, Failure>?
  fileprivate var completions: [CombineIdentifier: Promise] = [:]
  fileprivate let lock: Locking = RecursiveLock()
  public init(_ attemptToFulfill: @escaping (@escaping Promise) -> Void) {
    attemptToFulfill { (result) in
      self.lock.withLock {
        guard self.result == nil else {
          return
        }
        self.result = result
        while let key = self.completions.keys.first, let filfull = self.completions.removeValue(forKey: key) {
          filfull(result)
        }
      }
    }
  }
  private func _complete<S: _Subscriber>(_ result: Result<Output, Failure>, _ subscriber: S?) where Failure == S.Failure, Output == S.Input {
    switch result {
    case let .success(value):
      _ = subscriber?.receive(value)
      subscriber?.receive(completion: .finished)
    case let .failure(error):
      subscriber?.receive(completion: .failure(error))
    }
  }
  public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
    lock.withLock {
      let leading = _Subscriptions.Leading.Future(publisher: self, downstream: subscriber)
      let id = subscriber.combineIdentifier
      completions[id] = { (result) in
        self._complete(result, subscriber)
      }
      subscriber.receive(subscription: leading)
      if let result = self.result {
        self._complete(result, subscriber)
      }
    }
  }
}
private extension _Subscriptions.Leading {
  class Future<Downstream: _Subscriber>: _Subscriptions.Leading.Base<_Future<Downstream.Input, Downstream.Failure>, Downstream> {
    override func cancel() {
      guard let id = downstream?.combineIdentifier else {
        return
      }
      publisher.lock.withTryLock {
        _ = self.publisher.completions.removeValue(forKey: id)
      }
      downstream = nil
    }
    override func request(_ demand: _Subscribers.Demand) {

    }
    override var description: String {
      return "Future"
    }
  }
}
