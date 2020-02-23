extension _Publisher {
  /// Raises a fatal error when its upstream publisher fails, and otherwise republishes all received input.
  ///
  /// Use this function for internal sanity checks that are active during testing but do not impact performance of shipping code.
  ///
  /// - Parameters:
  ///   - prefix: A string used at the beginning of the fatal error message.
  ///   - file: A filename used in the error message. This defaults to `#file`.
  ///   - line: A line number used in the error message. This defaults to `#line`.
  /// - Returns: A publisher that raises a fatal error when its upstream publisher fails.
  public func assertNoFailure(_ prefix: String = "", file: StaticString = #file, line: UInt = #line) -> _Publishers.AssertNoFailure<Self> {
    return .init(upstream: self, prefix: prefix, file: file, line: line)
  }
}
extension _Publishers {
  /// A publisher that raises a fatal error upon receiving any failure, and otherwise republishes all received input.
  ///
  /// Use this function for internal sanity checks that are active during testing but do not impact performance of shipping code.
  public struct AssertNoFailure<Upstream: _Publisher>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Never
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// The string used at the beginning of the fatal error message.
    public let prefix: String
    /// The filename used in the error message.
    public let file: StaticString
    /// The line number used in the error message.
    public let line: UInt
    public init(upstream: Upstream, prefix: String, file: StaticString, line: UInt) {
      self.upstream = upstream
      self.prefix = prefix
      self.file = file
      self.line = line
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.Anonymous<Upstream.Output, Upstream.Failure, Downstream>(label: "AssertNoFailure", downstream: subscriber, receiveSubscription: { (channel, subscription) in
        channel.downstream.receive(subscription: subscription)
      }, receiveValue: { (channel, value) in
        return channel.downstream.receive(value)
      }, receiveCompletion: { (channel, completion) in
        channel.downstream.receive(completion: completion.mapError(transform: { (error) in
          let prefix = self.prefix.isEmpty ? "" : "\(self.prefix): "
          fatalError("\(prefix)\(error)", file: self.file, line: self.line)
        }))
      })
      upstream.subscribe(midstream)
    }
  }
}
