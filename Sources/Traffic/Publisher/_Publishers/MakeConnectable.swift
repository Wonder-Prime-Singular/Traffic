extension _Publisher where Self.Failure == Never {
  /// Creates a connectable wrapper around the publisher.
  ///
  /// - Returns: A `ConnectablePublisher` wrapping this publisher.
  public func makeConnectable() -> _Publishers.MakeConnectable<Self> {
    return .init(upstream: self)
  }
}
extension _Publishers {
  public struct MakeConnectable<Upstream: _Publisher>: _ConnectablePublisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Upstream.Failure
    public let upstream: Upstream
    public let multicast: Multicast<Upstream, _PassthroughSubject<Output, Failure>>
    public init(upstream: Upstream) {
      self.upstream = upstream
      multicast = upstream.multicast(subject: _PassthroughSubject<Output, Failure>())
    }
    public func receive<S: _Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
      multicast.subscribe(subscriber)
    }
    public func connect() -> _Cancellable {
      return multicast.connect()
    }
  }
}
