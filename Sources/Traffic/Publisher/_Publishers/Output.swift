extension _Publisher {
  /// Publishes a specific element, indicated by its index in the sequence of published elements.
  ///
  /// If the publisher completes normally or with an error before publishing the specified element, then the publisher doesn’t produce any elements.
  /// - Parameter index: The index that indicates the element to publish.
  /// - Returns: A publisher that publishes a specific indexed element.
  public func output(at index: Int) -> _Publishers.Output<Self> {
    return .init(upstream: self, range: .init(index ... index))
  }
  /// Publishes elements specified by their range in the sequence of published elements.
  ///
  /// After all elements are published, the publisher finishes normally.
  /// If the publisher completes normally or with an error before producing all the elements in the range, it doesn’t publish the remaining elements.
  /// - Parameter range: A range that indicates which elements to publish.
  /// - Returns: A publisher that publishes elements specified by a range.
  public func output<R: RangeExpression>(in range: R) -> _Publishers.Output<Self> where R.Bound == Int {
    return .init(upstream: self, range: range.relative(to: 0 ..< Int.max))
  }
}
extension _Publishers {
  /// A publisher that publishes elements specified by a range in the sequence of published elements.
  public struct Output<Upstream: _Publisher>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Upstream.Failure
    /// The publisher that this publisher receives elements from.
    public let upstream: Upstream
    /// The range of elements to publish.
    public let range: CountableRange<Int>
    /// Creates a publisher that publishes elements specified by a range.
    ///
    /// - Parameters:
    ///   - upstream: The publisher that this publisher receives elements from.
    ///   - range: The range of elements to publish.
    public init(upstream: Upstream, range: CountableRange<Int>) {
      self.upstream = upstream
      self.range = range
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      var index = 0
      let midstream = Channel.Anonymous<Upstream.Output, Upstream.Failure, Downstream>(label: "Output", downstream: subscriber, receiveSubscription: { (channel, subscription) in
        channel.downstream.receive(subscription: subscription)
      }, receiveValue: { (channel, value) in
        defer {
          index += 1
        }
        if self.range.contains(index) {
          return channel.downstream.receive(value)
        }
        return .unlimited
      }, receiveCompletion: { (channel, completion) in
        channel.downstream.receive(completion: completion)
      })
      upstream.subscribe(midstream)
    }
  }
}
extension _Publishers.Output: Equatable where Upstream: Equatable {
}
