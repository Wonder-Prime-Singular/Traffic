extension _Publisher {
  /// Returns a publisher as a class instance.
  ///
  /// The downstream subscriber receieves elements and completion states unchanged from the upstream publisher. Use this operator when you want to use reference semantics, such as storing a publisher instance in a property.
  ///
  /// - Returns: A class instance that republishes its upstream publisher.
  public func share() -> _Publishers.Share<Self> {
    return .init(upstream: self)
  }
}
extension _Publishers {
  /// A publisher implemented as a class, which otherwise behaves like its upstream publisher.
  public final class Share<Upstream: _Publisher>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Upstream.Failure
    public let upstream: Upstream
    public let publisher: Autoconnect<MakeConnectable<Upstream>>
    public init(upstream: Upstream) {
      self.upstream = upstream
      self.publisher = MakeConnectable(upstream: upstream).autoconnect()
    }
    public func receive<S: _Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
      publisher.subscribe(subscriber)
    }
  }
}
