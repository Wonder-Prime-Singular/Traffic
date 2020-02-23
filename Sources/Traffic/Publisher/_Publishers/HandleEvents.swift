extension _Publisher {
  /// Performs the specified closures when publisher events occur.
  ///
  /// - Parameters:
  ///   - receiveSubscription: A closure that executes when the publisher receives the  subscription from the upstream publisher. Defaults to `nil`.
  ///   - receiveOutput: A closure that executes when the publisher receives a value from the upstream publisher. Defaults to `nil`.
  ///   - receiveCompletion: A closure that executes when the publisher receives the completion from the upstream publisher. Defaults to `nil`.
  ///   - receiveCancel: A closure that executes when the downstream receiver cancels publishing. Defaults to `nil`.
  ///   - receiveRequest: A closure that executes when the publisher receives a request for more elements. Defaults to `nil`.
  /// - Returns: A publisher that performs the specified closures when publisher events occur.
  public func handleEvents(receiveSubscription: ((_Subscription) -> Void)? = nil, receiveOutput: ((Self.Output) -> Void)? = nil, receiveCompletion: ((_Subscribers.Completion<Self.Failure>) -> Void)? = nil, receiveCancel: (() -> Void)? = nil, receiveRequest: ((_Subscribers.Demand) -> Void)? = nil) -> _Publishers.HandleEvents<Self> {
    return .init(upstream: self, receiveSubscription: receiveSubscription, receiveOutput: receiveOutput, receiveCompletion: receiveCompletion, receiveCancel: receiveCancel, receiveRequest: receiveRequest)
  }
}
extension _Publishers {
  /// A publisher that performs the specified closures when publisher events occur.
  public struct HandleEvents<Upstream: _Publisher>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Upstream.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// A closure that executes when the publisher receives the subscription from the upstream publisher.
    public var receiveSubscription: ((_Subscription) -> Void)?
    ///  A closure that executes when the publisher receives a value from the upstream publisher.
    public var receiveOutput: ((Upstream.Output) -> Void)?
    /// A closure that executes when the publisher receives the completion from the upstream publisher.
    public var receiveCompletion: ((_Subscribers.Completion<Upstream.Failure>) -> Void)?
    ///  A closure that executes when the downstream receiver cancels publishing.
    public var receiveCancel: (() -> Void)?
    /// A closure that executes when the publisher receives a request for more elements.
    public var receiveRequest: ((_Subscribers.Demand) -> Void)?
    public init(upstream: Upstream, receiveSubscription: ((_Subscription) -> Void)? = nil, receiveOutput: ((Output) -> Void)? = nil, receiveCompletion: ((_Subscribers.Completion<Failure>) -> Void)? = nil, receiveCancel: (() -> Void)? = nil, receiveRequest: ((_Subscribers.Demand) -> Void)?) {
      self.upstream = upstream
      self.receiveSubscription = receiveSubscription
      self.receiveOutput = receiveOutput
      self.receiveCompletion = receiveCompletion
      self.receiveCancel = receiveCancel
      self.receiveRequest = receiveRequest
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.HandleEvents<Downstream>(handleEvents: self, downstream: subscriber)
      upstream.subscribe(midstream)
    }
  }
}
private extension _Publishers.Channel {
  class HandleEvents<Downstream: _Subscriber>: _Publishers.Channel.Base<Downstream.Input, Downstream.Failure, Downstream> {
    var receiveSubscription: ((_Subscription) -> Void)?
    var receiveOutput: ((Downstream.Input) -> Void)?
    var receiveCompletion: ((_Subscribers.Completion<Downstream.Failure>) -> Void)?
    var receiveCancel: (() -> Void)?
    var receiveRequest: ((_Subscribers.Demand) -> Void)?

    init<Upstream: _Publisher>(handleEvents: _Publishers.HandleEvents<Upstream>, downstream: Downstream) where Upstream.Output == Downstream.Input, Upstream.Failure == Downstream.Failure {
      self.receiveSubscription = handleEvents.receiveSubscription
      self.receiveOutput = handleEvents.receiveOutput
      self.receiveCompletion = handleEvents.receiveCompletion
      self.receiveCancel = handleEvents.receiveCancel
      self.receiveRequest = handleEvents.receiveRequest
      super.init(downstream: downstream)
    }
    override func receive(subscription: _Subscription) {
      guard super.shouldReceive(subscription: subscription) else {
        return
      }
      receiveSubscription?(subscription)
      let derived = DerivedSubscription(channel: self, subscription: subscription)
      downstream.receive(subscription: derived)
    }
    override func receive(_ input: Input) -> _Subscribers.Demand {
      guard super.isSubscribedAndNotCompleted() else {
        return .none
      }
      receiveOutput?(input)
      return downstream.receive(input)
    }
    override func receive(completion: _Subscribers.Completion<Failure>) {
      guard super.shouldReceiveCompletion(completion) else {
        return
      }
      receiveCompletion?(completion)
      downstream.receive(completion: completion)
    }
    override var description: String {
      return "HandleEvents"
    }
  }
  class DerivedSubscription<Downstream: _Subscriber>: _Subscription, CustomStringConvertible {
    weak var channel: HandleEvents<Downstream>?
    let subscription: _Subscription
    init(channel: HandleEvents<Downstream>?, subscription: _Subscription) {
      self.channel = channel
      self.subscription = subscription
    }
    func request(_ demand: _Subscribers.Demand) {
      guard channel?.shouldRequest(demand) == true else {
        return
      }
      subscription.request(demand)
      channel?.receiveRequest?(demand)
    }
    func cancel() {
      guard channel?.shouldCancel() == true else {
        return
      }
      subscription.cancel()
      channel?.receiveCancel?()
      channel?.event = .cancelled
    }
    var combineIdentifier: CombineIdentifier {
      return subscription.combineIdentifier
    }
    var description: String {
      return String(describing: subscription)
    }
  }
}
