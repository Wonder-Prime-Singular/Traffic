extension _ConnectablePublisher {
  /// Automates the process of connecting or disconnecting from this connectable publisher.
  ///
  /// Use `autoconnect()` to simplify working with `ConnectablePublisher` instances, such as those created with `makeConnectable()`.
  ///
  ///     let autoconnectedPublisher = somePublisher
  ///         .makeConnectable()
  ///         .autoconnect()
  ///         .subscribe(someSubscriber)
  ///
  /// - Returns: A publisher which automatically connects to its upstream connectable publisher.
  public func autoconnect() -> _Publishers.Autoconnect<Self> {
    return .init(upstream: self)
  }
}
extension _Publishers {
  /// A publisher that automatically connects and disconnects from this connectable publisher.
  public final class Autoconnect<Upstream: _ConnectablePublisher>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Upstream.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    var refCount: Int = 0 {
      didSet {
        if refCount > 0 {
          if connection == nil {
            connection = upstream.connect()
          }
        } else {
          connection?.cancel()
          connection = nil
        }
      }
    }
    private var connection: _Cancellable?
    internal let lock: Locking = Lock()
    public init(upstream: Upstream) {
      self.upstream = upstream
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.Autoconnect<Upstream, Downstream>(autoconnect: self, downstream: subscriber)
      upstream.subscribe(midstream)
    }
  }
}
private extension _Publishers.Channel {
  class Autoconnect<Upstream: _ConnectablePublisher, Downstream : _Subscriber>: _Publishers.Channel.Base<Upstream.Output, Upstream.Failure, Downstream> where Upstream.Output == Downstream.Input, Upstream.Failure == Downstream.Failure {
    var autoconnect: _Publishers.Autoconnect<Upstream>?
    init(autoconnect: _Publishers.Autoconnect<Upstream>, downstream: Downstream) {
      self.autoconnect = autoconnect
      super.init(downstream: downstream)
    }
    override func receive(subscription: _Subscription) {
      if let autoconnect = self.autoconnect {
        autoconnect.lock.withLock {
          autoconnect.refCount += 1
        }
      }
      let derived = DerivedSubscription(autoconnect: autoconnect, subscription: subscription)
      downstream.receive(subscription: derived)
    }
    override func receive(_ input: Input) -> _Subscribers.Demand {
      return downstream.receive(input)
    }
    override func receive(completion: _Subscribers.Completion<Failure>) {
      downstream.receive(completion: completion)
    }
    override var description: String {
      return "Autoconnect"
    }
  }
  class DerivedSubscription<Upstream: _ConnectablePublisher>: _Subscription, CustomStringConvertible {
    weak var autoconnect: _Publishers.Autoconnect<Upstream>?
    let subscription: _Subscription
    init(autoconnect: _Publishers.Autoconnect<Upstream>?, subscription: _Subscription) {
      self.autoconnect = autoconnect
      self.subscription = subscription
    }
    func request(_ demand: _Subscribers.Demand) {
      subscription.request(demand)
    }
    func cancel() {
      if let autoconnect = self.autoconnect {
        autoconnect.lock.withLock {
          autoconnect.refCount -= 1
        }
      }
      subscription.cancel()
    }
    var combineIdentifier: CombineIdentifier {
      return subscription.combineIdentifier
    }
    var description: String {
      return String(describing: subscription)
    }
  }
}
