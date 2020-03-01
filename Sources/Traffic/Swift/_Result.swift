public struct _Result<Success, Failure: Swift.Error> {
  public let base: Swift.Result<Success, Failure>
  public init(_ base: Swift.Result<Success, Failure>) {
    self.base = base
  }
}
extension Swift.Result {
  public var trafficResult: _Result<Success, Failure> {
    return .init(self)
  }
}
extension _Result {
  /// A publisher that publishes an output to each subscriber exactly once then finishes, or fails immediately without producing any elements.
  ///
  /// If `result` is `.success`, then `Once` waits until it receives a request for at least 1 value before sending the output. If `result` is `.failure`, then `Once` sends the failure immediately upon subscription.
  ///
  /// In contrast with `Just`, a `Once` publisher can terminate with an error instead of sending a value.
  /// In contrast with `Optional`, a `Once` publisher always sends one value (unless it terminates with an error).
  public struct Publisher: _Publisher {
    public typealias Output = Success
    /// The result to deliver to each subscriber.
    public let result: Swift.Result<Success, Failure>
    /// Creates a publisher that delivers the specified result.
    ///
    /// If the result is `.success`, the `Once` publisher sends the specified output to all subscribers and finishes normally. If the result is `.failure`, then the publisher fails immediately with the specified error.
    /// - Parameter result: The result to deliver to each subscriber.
    public init(_ result: Swift.Result<Output, Failure>) {
      self.result = result
    }
    /// Creates a publisher that sends the specified output to all subscribers and finishes normally.
    ///
    /// - Parameter output: The output to deliver to each subscriber.
    public init(_ output: Output) {
      result = .success(output)
    }
    /// Creates a publisher that immediately terminates upon subscription with the given failure.
    ///
    /// - Parameter failure: The failure to send when terminating.
    public init(_ failure: Failure) {
      result = .failure(failure)
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      switch result {
      case .success:
        let leading = _Subscriptions.Leading.Result(publisher: self, downstream: subscriber)
        subscriber.receive(subscription: leading)
      case let .failure(error):
        subscriber.receive(subscription: _Subscriptions.empty)
        subscriber.receive(completion: .failure(error))
      }
    }
  }
  public var publisher: _Result<Success, Failure>.Publisher {
    return .init(base)
  }
}
private extension _Subscriptions.Leading {
  class Result<Downstream: _Subscriber>: _Subscriptions.Leading.Base<_Result<Downstream.Input, Downstream.Failure>.Publisher, Downstream> {
    override func cancel() {
      downstream = nil
    }
    override func request(_ demand: _Subscribers.Demand) {
      guard let downstream = self.downstream else {
        return
      }
      self.downstream = nil
      _ = downstream.receive(try! publisher.result.get())
      downstream.receive(completion: .finished)
    }
    override var description: String {
      return "Once"
    }
  }
}
