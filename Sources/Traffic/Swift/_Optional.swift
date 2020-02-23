public struct _Optional<Wrapped> {
  public let base: Swift.Optional<Wrapped>
  public init(_ base: Swift.Optional<Wrapped>) {
    self.base = base
  }
}
extension Swift.Optional {
  public var trafficOptional: _Optional<Swift.Optional<Wrapped>> {
    return .init(self)
  }
}
extension _Optional {
  /// A publisher that publishes an optional value to each subscriber exactly once, if the optional has a value.
  ///
  /// In contrast with `Just`, an `Optional` publisher may send no value before completion.
  public struct Publisher: _Publisher {
    public typealias Output = Wrapped
    public typealias Failure = Never
    /// The result to deliver to each subscriber.
    public let output: Wrapped?
    /// Creates a publisher to emit the optional value of a successful result, or fail with an error.
    ///
    /// - Parameter result: The result to deliver to each subscriber.
    public init(_ output: Output?) {
      self.output = output
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      if output != nil {
        let leading = _Subscriptions.Leading.Optional(publisher: self, downstream: subscriber)
        subscriber.receive(subscription: leading)
      } else {
        subscriber.receive(subscription: _Subscriptions.empty)
        subscriber.receive(completion: .finished)
      }
    }
  }
  public var publisher: _Optional<Wrapped>.Publisher {
    return .init(base)
  }
}
private extension _Subscriptions.Leading {
  class Optional<Downstream: _Subscriber>: _Subscriptions.Leading.Base<_Optional<Downstream.Input>.Publisher, Downstream> where Downstream.Failure == Never {
    override func cancel() {
      downstream = nil
    }
    override func request(_ demand: _Subscribers.Demand) {
      _ = downstream?.receive(publisher.output!)
      downstream?.receive(completion: .finished)
    }
    override var description: String {
      return "Optional"
    }
  }
}
