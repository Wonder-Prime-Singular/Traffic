extension _Publisher {
  /// Prefixes a `Publisher`'s output with the specified sequence.
  /// - Parameter elements: The elements to publish before this publisher’s elements.
  /// - Returns: A publisher that prefixes the specified elements prior to this publisher’s elements.
  public func prepend(_ elements: Self.Output...) -> _Publishers.Concatenate<_Publishers.Sequence<[Self.Output], Self.Failure>, Self> {
    return .init(prefix: .init(sequence: elements), suffix: self)
  }
  /// Prefixes a `Publisher`'s output with the specified sequence.
  /// - Parameter elements: A sequence of elements to publish before this publisher’s elements.
  /// - Returns: A publisher that prefixes the sequence of elements prior to this publisher’s elements.
  public func prepend<S: Swift.Sequence>(_ elements: S) -> _Publishers.Concatenate<_Publishers.Sequence<S, Self.Failure>, Self> where Self.Output == S.Element {
    return .init(prefix: .init(sequence: elements), suffix: self)
  }
  /// Prefixes this publisher’s output with the elements emitted by the given publisher.
  ///
  /// The resulting publisher doesn’t emit any elements until the prefixing publisher finishes.
  /// - Parameter publisher: The prefixing publisher.
  /// - Returns: A publisher that prefixes the prefixing publisher’s elements prior to this publisher’s elements.
  public func prepend<P: _Publisher>(_ publisher: P) -> _Publishers.Concatenate<P, Self> where Self.Failure == P.Failure, Self.Output == P.Output {
    return .init(prefix: publisher, suffix: self)
  }
  /// Append a `Publisher`'s output with the specified sequence.
  public func append(_ elements: Self.Output...) -> _Publishers.Concatenate<Self, _Publishers.Sequence<[Self.Output], Self.Failure>> {
    return .init(prefix: self, suffix: .init(sequence: elements))
  }
  /// Appends a `Publisher`'s output with the specified sequence.
  public func append<S: Swift.Sequence>(_ elements: S) -> _Publishers.Concatenate<Self, _Publishers.Sequence<S, Self.Failure>> where Self.Output == S.Element {
    return .init(prefix: self, suffix: .init(sequence: elements))
  }
  /// Appends this publisher’s output with the elements emitted by the given publisher.
  ///
  /// This operator produces no elements until this publisher finishes. It then produces this publisher’s elements, followed by the given publisher’s elements. If this publisher fails with an error, the prefixing publisher does not publish the provided publisher’s elements.
  /// - Parameter publisher: The appending publisher.
  /// - Returns: A publisher that appends the appending publisher’s elements after this publisher’s elements.
  public func append<P: _Publisher>(_ publisher: P) -> _Publishers.Concatenate<Self, P> where Self.Failure == P.Failure, Self.Output == P.Output {
    return .init(prefix: self, suffix: publisher)
  }
}
extension _Publishers.Concatenate: Equatable where Prefix: Equatable, Suffix: Equatable {}
extension _Publishers {
  /// A publisher that emits all of one publisher’s elements before those from another publisher.
  public struct Concatenate<Prefix: _Publisher, Suffix: _Publisher>: _Publisher where Prefix.Failure == Suffix.Failure, Prefix.Output == Suffix.Output {
    public typealias Output = Suffix.Output
    public typealias Failure = Suffix.Failure
    /// The publisher to republish, in its entirety, before republishing elements from `suffix`.
    public let prefix: Prefix
    /// The publisher to republish only after `prefix` finishes.
    public let suffix: Suffix
    public init(prefix: Prefix, suffix: Suffix) {
      self.prefix = prefix
      self.suffix = suffix
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.Concatenate<Suffix, Downstream>(suffixUpStream: suffix, downstream: subscriber)
      prefix.subscribe(midstream)
    }
  }
}
private extension _Publishers.Channel {
  class Concatenate<Suffix: _Publisher, Downstream: _Subscriber>: _Publishers.Channel.Base<Downstream.Input, Downstream.Failure, Downstream> where Downstream.Input == Suffix.Output, Downstream.Failure == Suffix.Failure {
    let lock: Locking = RecursiveLock()
    var isPrefixCompleted: Bool = false
    var suffixUpStream: Suffix?
    init(suffixUpStream: Suffix, downstream: Downstream) {
      self.suffixUpStream = suffixUpStream
      super.init(downstream: downstream)
    }
    override func receive(subscription: _Subscription) {
      lock.withLock {
        guard super.shouldReceive(subscription: subscription) else {
          return
        }
        if isPrefixCompleted {
          subscription.request(self.demand)
        } else {
          downstream.receive(subscription: self)
        }
      }
    }
    override func receive(_ input: Input) -> _Subscribers.Demand {
      return lock.withLock {
        guard self.isSubscribed() else {
          return .none
        }
        return downstream.receive(input)
      }
    }
    override func receive(completion: _Subscribers.Completion<Failure>) {
      lock.withLock {
        if !isPrefixCompleted {
          if case .finished = completion {
            self.event = .pending
            isPrefixCompleted = true
            suffixUpStream?.subscribe(self)
            suffixUpStream = nil
          } else {
            downstream.receive(completion: completion)
          }
        } else {
          guard super.shouldReceiveCompletion(completion) else {
            return
          }
          downstream.receive(completion: completion)
        }
      }
    }
    override var description: String {
      return "Concatenate"
    }
  }
}
