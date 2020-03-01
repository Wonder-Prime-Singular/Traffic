extension _Publisher {
  /// Prints log messages for all publishing events.
  ///
  /// - Parameter prefix: A string with which to prefix all log messages. Defaults to an empty string.
  /// - Returns: A publisher that prints log messages for all publishing events.
  public func print(_ prefix: String = "", to stream: TextOutputStream? = nil) -> _Publishers.Print<Self> {
    return .init(upstream: self, prefix: prefix, to: stream)
  }
}
extension _Publishers {
  /// A publisher that prints log messages for all publishing events, optionally prefixed with a given string.
  ///
  /// This publisher prints log messages when receiving the following events:
  /// * subscription
  /// * value
  /// * normal completion
  /// * failure
  /// * cancellation
  public struct Print<Upstream: _Publisher>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Upstream.Failure
    /// A string with which to prefix all log messages.
    public let prefix: String
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    public let stream: TextOutputStream?
    /// Creates a publisher that prints log messages for all publishing events.
    ///
    /// - Parameters:
    ///   - upstream: The publisher from which this publisher receives elements.
    ///   - prefix: A string with which to prefix all log messages.
    public init(upstream: Upstream, prefix: String, to stream: TextOutputStream? = nil) {
      self.upstream = upstream
      self.prefix = prefix
      self.stream = stream
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.Print<Downstream>(print: self, downstream: subscriber)
      upstream.subscribe(midstream)
    }
  }
}
private extension _Publishers.Channel {
  class Print<Downstream: _Subscriber>: _Publishers.Channel.Base<Downstream.Input, Downstream.Failure, Downstream> {
    let lock = Lock()
    var prefixClosure: (() -> String)?
    var prefix: String = ""
    var stream: TextOutputStream?
    init<Upstream: _Publisher>(print: _Publishers.Print<Upstream>, downstream: Downstream) where Upstream.Output == Downstream.Input, Upstream.Failure ==Downstream.Failure {
      self.prefixClosure = {
        print.prefix.isEmpty ? "" : "\(print.prefix): "
      }
      self.stream = print.stream
      super.init(downstream: downstream)
    }
    func write(_ message: @autoclosure () -> String) -> Void {
      lock.withLock {
        if var t = stream {
          t.write(message())
          stream = t
        } else {
          Swift.print(message())
        }
      }
    }
    override func receive(subscription: _Subscription) {
      guard super.shouldReceive(subscription: subscription) else {
        return
      }
      if prefixClosure != nil {
        prefix = prefixClosure!()
        prefixClosure = nil
      }
      write("\(prefix)receive subscription: (\(subscription))")
      let derived = DerivedSubscription(channel: self, subscription: subscription)
      downstream.receive(subscription: derived)
    }
    override func receive(_ input: Input) -> _Subscribers.Demand {
      guard super.isSubscribedAndNotCompleted() else {
        return .none
      }
      write("\(prefix)receive value: (\(input))")
      return downstream.receive(input)
    }
    override func receive(completion: _Subscribers.Completion<Failure>) {
      guard super.shouldReceiveCompletion(completion) else {
        return
      }
      switch completion {
      case .finished:
        write("\(prefix)receive finished")
      case let .failure(error):
        write("\(prefix)receive error: (\(error))")
      }
      downstream.receive(completion: completion)
    }
    override var description: String {
      return "Print"
    }
  }
  class DerivedSubscription<Downstream: _Subscriber>: _Subscription, CustomStringConvertible {
    weak var channel: Print<Downstream>?
    let subscription: _Subscription
    init(channel: Print<Downstream>?, subscription: _Subscription) {
      self.channel = channel
      self.subscription = subscription
    }
    func request(_ demand: _Subscribers.Demand) {
      if let channel = channel {
        channel.write("\(channel.prefix)request \(demand)")
      }
      subscription.request(demand)
    }
    func cancel() {
      if let channel = channel {
        channel.write("\(channel.prefix)receive cancel")
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
