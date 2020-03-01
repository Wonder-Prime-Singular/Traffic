extension _Subscriptions {
  public enum Leading {
    open class Simple<Downstream: _Subscriber>: _Subscription, CustomStringConvertible {
      public var downstream: Downstream?
      open var isCancelled: Bool = false
      public let lock: Locking = RecursiveLock()
      open var demand: _Subscribers.Demand = .none
      public init(downstream: Downstream) {
        self.downstream = downstream
      }
      open func request(_ demand: _Subscribers.Demand) {
        traffic_abstract_method()
      }
      open func cancel() {
        traffic_abstract_method()
      }
      open var description: String {
        traffic_abstract_method()
      }
    }
    open class Base<P: _Publisher, Downstream: _Subscriber>: Simple<Downstream> where P.Output == Downstream.Input, P.Failure == Downstream.Failure {
      public var publisher: P
      public init(publisher: P, downstream: Downstream) {
        self.publisher = publisher
        super.init(downstream: downstream)
      }
    }
    open class Subject<S: _Subject>: Simple<_AnySubscriber<S.Output, S.Failure>> {
      var subject: S?
      public init<Downstream: _Subscriber>(subject: S, downstream: Downstream) where Downstream.Input == S.Output, Downstream.Failure == S.Failure {
        self.subject = subject
        super.init(downstream: _AnySubscriber<S.Output, S.Failure>(downstream))
      }
      open func receive(_ input: S.Output) {
        traffic_abstract_method()
      }
      open func receive(completion: _Subscribers.Completion<S.Failure>) {
        traffic_abstract_method()
      }
    }
  }
}
