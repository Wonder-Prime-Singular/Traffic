import Darwin.C.signal
extension _Publisher {
  /// Raises a debugger signal when a provided closure needs to stop the process in the debugger.
  ///
  /// When any of the provided closures returns `true`, this publisher raises the `SIGTRAP` signal to stop the process in the debugger.
  /// Otherwise, this publisher passes through values and completions as-is.
  ///
  /// - Parameters:
  ///   - receiveSubscription: A closure that executes when when the publisher receives a subscription. Return `true` from this closure to raise `SIGTRAP`, or false to continue.
  ///   - receiveOutput: A closure that executes when when the publisher receives a value. Return `true` from this closure to raise `SIGTRAP`, or false to continue.
  ///   - receiveCompletion: A closure that executes when when the publisher receives a completion. Return `true` from this closure to raise `SIGTRAP`, or false to continue.
  /// - Returns: A publisher that raises a debugger signal when one of the provided closures returns `true`.
  public func breakpoint(receiveSubscription: ((_Subscription) -> Bool)? = nil, receiveOutput: ((Self.Output) -> Bool)? = nil, receiveCompletion: ((_Subscribers.Completion<Self.Failure>) -> Bool)? = nil) -> _Publishers.Breakpoint<Self> {
    return .init(upstream: self, receiveSubscription: receiveSubscription, receiveOutput: receiveOutput, receiveCompletion: receiveCompletion)
  }
  /// Raises a debugger signal upon receiving a failure.
  ///
  /// When the upstream publisher fails with an error, this publisher raises the `SIGTRAP` signal, which stops the process in the debugger.
  /// Otherwise, this publisher passes through values and completions as-is.
  /// - Returns: A publisher that raises a debugger signal upon receiving a failure.
  public func breakpointOnError() -> _Publishers.Breakpoint<Self> {
    return breakpoint(receiveSubscription: nil, receiveOutput: nil, receiveCompletion: { (completion) in
      if case .failure = completion {
        return true
      } else {
        return false
      }
    })
  }
}
extension _Publishers {
  public struct Breakpoint<Upstream: _Publisher>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Upstream.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// A closure that executes when the publisher receives a subscription, and can raise a debugger signal by returning a true Boolean value.
    public let receiveSubscription: ((_Subscription) -> Bool)?
    /// A closure that executes when the publisher receives output from the upstream publisher, and can raise a debugger signal by returning a true Boolean value.
    public let receiveOutput: ((Upstream.Output) -> Bool)?
    /// A closure that executes when the publisher receives completion, and can raise a debugger signal by returning a true Boolean value.
    public let receiveCompletion: ((_Subscribers.Completion<Upstream.Failure>) -> Bool)?
    /// Creates a breakpoint publisher with the provided upstream publisher and breakpoint-raising closures.
    ///
    /// - Parameters:
    ///   - upstream: The publisher from which this publisher receives elements.
    ///   - receiveSubscription: A closure that executes when the publisher receives a subscription, and can raise a debugger signal by returning a true Boolean value.
    ///   - receiveOutput: A closure that executes when the publisher receives output from the upstream publisher, and can raise a debugger signal by returning a true Boolean value.
    ///   - receiveCompletion: A closure that executes when the publisher receives completion, and can raise a debugger signal by returning a true Boolean value.
    public init(upstream: Upstream, receiveSubscription: ((_Subscription) -> Bool)? = nil, receiveOutput: ((Upstream.Output) -> Bool)? = nil, receiveCompletion: ((_Subscribers.Completion<Failure>) -> Bool)? = nil) {
      self.upstream = upstream
      self.receiveSubscription = receiveSubscription
      self.receiveOutput = receiveOutput
      self.receiveCompletion = receiveCompletion
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.Anonymous<Upstream.Output, Upstream.Failure, Downstream>(label: "Breakpoint", downstream: subscriber, receiveSubscription: { (channel, subscription) in
        if self.receiveSubscription?(subscription) == true { raise(SIGTRAP) }
        channel.downstream.receive(subscription: subscription)
      }, receiveValue: { (channel, value) in
        if self.receiveOutput?(value) == true { raise(SIGTRAP) }
        let demand = channel.downstream.receive(value)
        return demand
      }, receiveCompletion: { (channel, completion) in
        if self.receiveCompletion?(completion) == true { raise(SIGTRAP) }
        channel.downstream.receive(completion: completion)
      })
      upstream.subscribe(midstream)
    }
  }
}
