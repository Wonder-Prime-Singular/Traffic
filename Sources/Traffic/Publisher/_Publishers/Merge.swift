extension _Publisher {
  /// Combines elements from this publisher with those from another publisher, delivering an interleaved sequence of elements.
  ///
  /// The merged publisher continues to emit elements until all upstream publishers finish. If an upstream publisher produces an error, the merged publisher fails with that error.
  /// - Parameter other: Another publisher.
  /// - Returns: A publisher that emits an event when either upstream publisher emits an event.
  public func merge<P: _Publisher>(with other: P) -> _Publishers.Merge<Self, P> where Self.Failure == P.Failure, Self.Output == P.Output {
    return .init(self, other)
  }
  /// Combines elements from this publisher with those from another publisher, delivering an interleaved sequence of elements.
  ///
  /// The merged publisher continues to emit elements until all upstream publishers finish. If an upstream publisher produces an error, the merged publisher fails with that error.
  /// - Parameter other: Another publisher.
  /// - Returns: A publisher that emits an event when either upstream publisher emits an event.
  public func merge<B: _Publisher, C: _Publisher>(with b: B, _ c: C) -> _Publishers.Merge3<Self, B, C> where Self.Failure == B.Failure, Self.Output == B.Output, B.Failure == C.Failure, B.Output == C.Output {
    return .init(self, b, c)
  }
  /// Combines elements from this publisher with those from three other publishers, delivering
  /// an interleaved sequence of elements.
  ///
  /// The merged publisher continues to emit elements until all upstream publishers finish. If an upstream publisher produces an error, the merged publisher fails with that error.
  ///
  /// - Parameters:
  ///   - b: A second publisher.
  ///   - c: A third publisher.
  ///   - d: A fourth publisher.
  /// - Returns: A publisher that emits an event when any upstream publisher emits an event.
  public func merge<B: _Publisher, C: _Publisher, D: _Publisher>(with b: B, _ c: C, _ d: D) -> _Publishers.Merge4<Self, B, C, D> where Self.Failure == B.Failure, Self.Output == B.Output, B.Failure == C.Failure, B.Output == C.Output, C.Failure == D.Failure, C.Output == D.Output {
    return .init(self, b, c, d)
  }
  /// Combines elements from this publisher with those from four other publishers, delivering an interleaved sequence of elements.
  ///
  /// The merged publisher continues to emit elements until all upstream publishers finish. If an upstream publisher produces an error, the merged publisher fails with that error.
  ///
  /// - Parameters:
  ///   - b: A second publisher.
  ///   - c: A third publisher.
  ///   - d: A fourth publisher.
  ///   - e: A fifth publisher.
  /// - Returns: A publisher that emits an event when any upstream publisher emits an event.
  public func merge<B: _Publisher, C: _Publisher, D: _Publisher, E: _Publisher>(with b: B, _ c: C, _ d: D, _ e: E) -> _Publishers.Merge5<Self, B, C, D, E> where Self.Failure == B.Failure, Self.Output == B.Output, B.Failure == C.Failure, B.Output == C.Output, C.Failure == D.Failure, C.Output == D.Output, D.Failure == E.Failure, D.Output == E.Output {
    return .init(self, b, c, d, e)
  }
  /// Combines elements from this publisher with those from five other publishers, delivering an interleaved sequence of elements.
  ///
  /// The merged publisher continues to emit elements until all upstream publishers finish. If an upstream publisher produces an error, the merged publisher fails with that error.
  ///
  /// - Parameters:
  ///   - b: A second publisher.
  ///   - c: A third publisher.
  ///   - d: A fourth publisher.
  ///   - e: A fifth publisher.
  ///   - f: A sixth publisher.
  /// - Returns: A publisher that emits an event when any upstream publisher emits an event.
  public func merge<B: _Publisher, C: _Publisher, D: _Publisher, E: _Publisher, F: _Publisher>(with b: B, _ c: C, _ d: D, _ e: E, _ f: F) -> _Publishers.Merge6<Self, B, C, D, E, F> where Self.Failure == B.Failure, Self.Output == B.Output, B.Failure == C.Failure, B.Output == C.Output, C.Failure == D.Failure, C.Output == D.Output, D.Failure == E.Failure, D.Output == E.Output, E.Failure == F.Failure, E.Output == F.Output {
    return .init(self, b, c, d, e, f)
  }
  /// Combines elements from this publisher with those from six other publishers, delivering an interleaved sequence of elements.
  ///
  /// The merged publisher continues to emit elements until all upstream publishers finish. If an upstream publisher produces an error, the merged publisher fails with that error.
  ///
  /// - Parameters:
  ///   - b: A second publisher.
  ///   - c: A third publisher.
  ///   - d: A fourth publisher.
  ///   - e: A fifth publisher.
  ///   - f: A sixth publisher.
  ///   - g: A seventh publisher.
  /// - Returns: A publisher that emits an event when any upstream publisher emits an event.
  public func merge<B: _Publisher, C: _Publisher, D: _Publisher, E: _Publisher, F: _Publisher, G: _Publisher>(with b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G) -> _Publishers.Merge7<Self, B, C, D, E, F, G> where Self.Failure == B.Failure, Self.Output == B.Output, B.Failure == C.Failure, B.Output == C.Output, C.Failure == D.Failure, C.Output == D.Output, D.Failure == E.Failure, D.Output == E.Output, E.Failure == F.Failure, E.Output == F.Output, F.Failure == G.Failure, F.Output == G.Output {
    return .init(self, b, c, d, e, f, g)
  }
  /// Combines elements from this publisher with those from seven other publishers, delivering an interleaved sequence of elements.
  ///
  /// The merged publisher continues to emit elements until all upstream publishers finish. If an upstream publisher produces an error, the merged publisher fails with that error.
  ///
  /// - Parameters:
  ///   - b: A second publisher.
  ///   - c: A third publisher.
  ///   - d: A fourth publisher.
  ///   - e: A fifth publisher.
  ///   - f: A sixth publisher.
  ///   - g: A seventh publisher.
  ///   - h: An eighth publisher.
  /// - Returns: A publisher that emits an event when any upstream publisher emits an event.
  public func merge<B: _Publisher, C: _Publisher, D: _Publisher, E: _Publisher, F: _Publisher, G: _Publisher, H: _Publisher>(with b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H) -> _Publishers.Merge8<Self, B, C, D, E, F, G, H> where Self.Failure == B.Failure, Self.Output == B.Output, B.Failure == C.Failure, B.Output == C.Output, C.Failure == D.Failure, C.Output == D.Output, D.Failure == E.Failure, D.Output == E.Output, E.Failure == F.Failure, E.Output == F.Output, F.Failure == G.Failure, F.Output == G.Output, G.Failure == H.Failure, G.Output == H.Output {
    return .init(self, b, c, d, e, f, g, h)
  }
  /// Combines elements from this publisher with those from another publisher of the same type, delivering an interleaved sequence of elements.
  ///
  /// - Parameter other: Another publisher of this publisher's type.
  /// - Returns: A publisher that emits an event when either upstream publisher emits
  /// an event.
  public func merge(with other: Self) -> _Publishers.MergeMany<Self> {
    return .init([self, other])
  }
}
extension _Publishers {
  /// A publisher created by applying the merge function to two upstream publishers.
  public struct Merge<A: _Publisher, B: _Publisher>: _Publisher where A.Failure == B.Failure, A.Output == B.Output {
    public typealias Output = A.Output
    public typealias Failure = A.Failure
    public let a: A
    public let b: B
    public init(_ a: A, _ b: B) {
      self.a = a
      self.b = b
    }
    public func receive<S: _Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
      let midstream = Channel.Merge(downstream: subscriber)
      a.subscribe(midstream)
      b.subscribe(midstream)
    }
    public func merge<P: _Publisher>(with other: P) -> Merge3<A, B, P> where B.Failure == P.Failure, B.Output == P.Output {
      return .init(a, b, other)
    }
    public func merge<Z: _Publisher, Y: _Publisher>(with z: Z, _ y: Y) -> Merge4<A, B, Z, Y> where B.Failure == Z.Failure, B.Output == Z.Output, Z.Failure == Y.Failure, Z.Output == Y.Output {
      return .init(a, b, z, y)
    }
    public func merge<Z: _Publisher, Y: _Publisher, X: _Publisher>(with z: Z, _ y: Y, _ x: X) -> Merge5<A, B, Z, Y, X> where B.Failure == Z.Failure, B.Output == Z.Output, Z.Failure == Y.Failure, Z.Output == Y.Output, Y.Failure == X.Failure, Y.Output == X.Output {
      return .init(a, b, z, y, x)
    }
    public func merge<Z: _Publisher, Y: _Publisher, X: _Publisher, W: _Publisher>(with z: Z, _ y: Y, _ x: X, _ w: W) -> Merge6<A, B, Z, Y, X, W> where B.Failure == Z.Failure, B.Output == Z.Output, Z.Failure == Y.Failure, Z.Output == Y.Output, Y.Failure == X.Failure, Y.Output == X.Output, X.Failure == W.Failure, X.Output == W.Output {
      return .init(a, b, z, y, x, w)
    }
    public func merge<Z: _Publisher, Y: _Publisher, X: _Publisher, W: _Publisher, V: _Publisher>(with z: Z, _ y: Y, _ x: X, _ w: W, _ v: V) -> Merge7<A, B, Z, Y, X, W, V> where B.Failure == Z.Failure, B.Output == Z.Output, Z.Failure == Y.Failure, Z.Output == Y.Output, Y.Failure == X.Failure, Y.Output == X.Output, X.Failure == W.Failure, X.Output == W.Output, W.Failure == V.Failure, W.Output == V.Output {
      return .init(a, b, z, y, x, w, v)
    }
    public func merge<Z: _Publisher, Y: _Publisher, X: _Publisher, W: _Publisher, V: _Publisher, U: _Publisher>(with z: Z, _ y: Y, _ x: X, _ w: W, _ v: V, _ u: U) -> Merge8<A, B, Z, Y, X, W, V, U> where B.Failure == Z.Failure, B.Output == Z.Output, Z.Failure == Y.Failure, Z.Output == Y.Output, Y.Failure == X.Failure, Y.Output == X.Output, X.Failure == W.Failure, X.Output == W.Output, W.Failure == V.Failure, W.Output == V.Output, V.Failure == U.Failure, V.Output == U.Output {
      return .init(a, b, z, y, x, w, v, u)
    }
  }
  /// A publisher created by applying the merge function to two upstream publishers.
  public struct Merge3<A: _Publisher, B: _Publisher, C: _Publisher>: _Publisher where A.Failure == B.Failure, A.Output == B.Output, A.Failure == C.Failure, A.Output == C.Output {
    public typealias Output = A.Output
    public typealias Failure = A.Failure
    public let a: A
    public let b: B
    public let c: C
    public init(_ a: A, _ b: B, _ c: C) {
      self.a = a
      self.b = b
      self.c = c
    }
    public func receive<S: _Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
      let midstream = Channel.Merge(downstream: subscriber)
      a.subscribe(midstream)
      b.subscribe(midstream)
      c.subscribe(midstream)
    }
    public func merge<P: _Publisher>(with other: P) -> Merge4<A, B, C, P> where C.Failure == P.Failure, C.Output == P.Output {
      return .init(a, b, c, other)
    }
    public func merge<Z: _Publisher, Y: _Publisher>(with z: Z, _ y: Y) -> Merge5<A, B, C, Z, Y> where C.Failure == Z.Failure, C.Output == Z.Output, Z.Failure == Y.Failure, Z.Output == Y.Output {
      return .init(a, b, c, z, y)
    }
    public func merge<Z: _Publisher, Y: _Publisher, X: _Publisher>(with z: Z, _ y: Y, _ x: X) -> Merge6<A, B, C, Z, Y, X> where C.Failure == Z.Failure, C.Output == Z.Output, Z.Failure == Y.Failure, Z.Output == Y.Output, Y.Failure == X.Failure, Y.Output == X.Output {
      return .init(a, b, c, z, y, x)
    }
    public func merge<Z: _Publisher, Y: _Publisher, X: _Publisher, W: _Publisher>(with z: Z, _ y: Y, _ x: X, _ w: W) -> Merge7<A, B, C, Z, Y, X, W> where C.Failure == Z.Failure, C.Output == Z.Output, Z.Failure == Y.Failure, Z.Output == Y.Output, Y.Failure == X.Failure, Y.Output == X.Output, X.Failure == W.Failure, X.Output == W.Output {
      return .init(a, b, c, z, y, x, w)
    }
    public func merge<Z: _Publisher, Y: _Publisher, X: _Publisher, W: _Publisher, V: _Publisher>(with z: Z, _ y: Y, _ x: X, _ w: W, _ v: V) -> Merge8<A, B, C, Z, Y, X, W, V> where C.Failure == Z.Failure, C.Output == Z.Output, Z.Failure == Y.Failure, Z.Output == Y.Output, Y.Failure == X.Failure, Y.Output == X.Output, X.Failure == W.Failure, X.Output == W.Output, W.Failure == V.Failure, W.Output == V.Output {
      return .init(a, b, c, z, y, x, w, v)
    }
  }
  /// A publisher created by applying the merge function to four upstream Publishers.
  public struct Merge4<A: _Publisher, B: _Publisher, C: _Publisher, D: _Publisher>: _Publisher where A.Failure == B.Failure, A.Output == B.Output, B.Failure == C.Failure, B.Output == C.Output, C.Failure == D.Failure, C.Output == D.Output {
    public typealias Output = A.Output
    public typealias Failure = A.Failure
    public let a: A
    public let b: B
    public let c: C
    public let d: D
    public init(_ a: A, _ b: B, _ c: C, _ d: D) {
      self.a = a
      self.b = b
      self.c = c
      self.d = d
    }
    public func receive<S: _Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
      let midstream = Channel.Merge(downstream: subscriber)
      a.subscribe(midstream)
      b.subscribe(midstream)
      c.subscribe(midstream)
      d.subscribe(midstream)
    }
    public func merge<P: _Publisher>(with other: P) -> Merge5<A, B, C, D, P> where D.Failure == P.Failure, D.Output == P.Output {
      return .init(a, b, c, d, other)
    }
    public func merge<Z: _Publisher, Y: _Publisher>(with z: Z, _ y: Y) -> Merge6<A, B, C, D, Z, Y> where D.Failure == Z.Failure, D.Output == Z.Output, Z.Failure == Y.Failure, Z.Output == Y.Output {
      return .init(a, b, c, d, z, y)
    }
    public func merge<Z: _Publisher, Y: _Publisher, X: _Publisher>(with z: Z, _ y: Y, _ x: X) -> Merge7<A, B, C, D, Z, Y, X> where D.Failure == Z.Failure, D.Output == Z.Output, Z.Failure == Y.Failure, Z.Output == Y.Output, Y.Failure == X.Failure, Y.Output == X.Output {
      return .init(a, b, c, d, z, y, x)
    }
    public func merge<Z: _Publisher, Y: _Publisher, X: _Publisher, W: _Publisher>(with z: Z, _ y: Y, _ x: X, _ w: W) -> Merge8<A, B, C, D, Z, Y, X, W> where D.Failure == Z.Failure, D.Output == Z.Output, Z.Failure == Y.Failure, Z.Output == Y.Output, Y.Failure == X.Failure, Y.Output == X.Output, X.Failure == W.Failure, X.Output == W.Output {
      return .init(a, b, c, d, z, y, x, w)
    }
  }
  /// A publisher created by applying the merge function to five upstream Publishers.
  public struct Merge5<A: _Publisher, B: _Publisher, C: _Publisher, D: _Publisher, E: _Publisher>: _Publisher where A.Failure == B.Failure, A.Output == B.Output, B.Failure == C.Failure, B.Output == C.Output, C.Failure == D.Failure, C.Output == D.Output, D.Failure == E.Failure, D.Output == E.Output {
    public typealias Output = A.Output
    public typealias Failure = A.Failure
    public let a: A
    public let b: B
    public let c: C
    public let d: D
    public let e: E
    public init(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E) {
      self.a = a
      self.b = b
      self.c = c
      self.d = d
      self.e = e
    }
    public func receive<S: _Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
      let midstream = Channel.Merge(downstream: subscriber)
      a.subscribe(midstream)
      b.subscribe(midstream)
      c.subscribe(midstream)
      d.subscribe(midstream)
      e.subscribe(midstream)
    }
    public func merge<P: _Publisher>(with other: P) -> Merge6<A, B, C, D, E, P> where E.Failure == P.Failure, E.Output == P.Output {
      return .init(a, b, c, d, e, other)
    }
    public func merge<Z: _Publisher, Y: _Publisher>(with z: Z, _ y: Y) -> Merge7<A, B, C, D, E, Z, Y> where E.Failure == Z.Failure, E.Output == Z.Output, Z.Failure == Y.Failure, Z.Output == Y.Output {
      return .init(a, b, c, d, e, z, y)
    }
    public func merge<Z: _Publisher, Y: _Publisher, X: _Publisher>(with z: Z, _ y: Y, _ x: X) -> Merge8<A, B, C, D, E, Z, Y, X> where E.Failure == Z.Failure, E.Output == Z.Output, Z.Failure == Y.Failure, Z.Output == Y.Output, Y.Failure == X.Failure, Y.Output == X.Output {
      return .init(a, b, c, d, e, z, y, x)
    }
  }
  /// A publisher created by applying the merge function to six upstream Publishers.
  public struct Merge6<A: _Publisher, B: _Publisher, C: _Publisher, D: _Publisher, E: _Publisher, F: _Publisher>: _Publisher where A.Failure == B.Failure, A.Output == B.Output, B.Failure == C.Failure, B.Output == C.Output, C.Failure == D.Failure, C.Output == D.Output, D.Failure == E.Failure, D.Output == E.Output, E.Failure == F.Failure, E.Output == F.Output {
    public typealias Output = A.Output
    public typealias Failure = A.Failure
    public let a: A
    public let b: B
    public let c: C
    public let d: D
    public let e: E
    public let f: F
    public init(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F) {
      self.a = a
      self.b = b
      self.c = c
      self.d = d
      self.e = e
      self.f = f
    }
    public func receive<S: _Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
      let midstream = Channel.Merge(downstream: subscriber)
      a.subscribe(midstream)
      b.subscribe(midstream)
      c.subscribe(midstream)
      d.subscribe(midstream)
      e.subscribe(midstream)
      f.subscribe(midstream)
    }
    public func merge<P: _Publisher>(with other: P) -> Merge7<A, B, C, D, E, F, P> where F.Failure == P.Failure, F.Output == P.Output {
      return .init(a, b, c, d, e, f, other)
    }
    public func merge<Z: _Publisher, Y: _Publisher>(with z: Z, _ y: Y) -> Merge8<A, B, C, D, E, F, Z, Y> where F.Failure == Z.Failure, F.Output == Z.Output, Z.Failure == Y.Failure, Z.Output == Y.Output {
      return .init(a, b, c, d, e, f, z, y)
    }
  }
  /// A publisher created by applying the merge function to seven upstream Publishers.
  public struct Merge7<A: _Publisher, B: _Publisher, C: _Publisher, D: _Publisher, E: _Publisher, F: _Publisher, G: _Publisher>: _Publisher where A.Failure == B.Failure, A.Output == B.Output, B.Failure == C.Failure, B.Output == C.Output, C.Failure == D.Failure, C.Output == D.Output, D.Failure == E.Failure, D.Output == E.Output, E.Failure == F.Failure, E.Output == F.Output, F.Failure == G.Failure, F.Output == G.Output {
    public typealias Output = A.Output
    public typealias Failure = A.Failure
    public let a: A
    public let b: B
    public let c: C
    public let d: D
    public let e: E
    public let f: F
    public let g: G
    public init(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G) {
      self.a = a
      self.b = b
      self.c = c
      self.d = d
      self.e = e
      self.f = f
      self.g = g
    }
    public func receive<S: _Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
      let midstream = Channel.Merge(downstream: subscriber)
      a.subscribe(midstream)
      b.subscribe(midstream)
      c.subscribe(midstream)
      d.subscribe(midstream)
      e.subscribe(midstream)
      f.subscribe(midstream)
      g.subscribe(midstream)
    }
    public func merge<P: _Publisher>(with other: P) -> Merge8<A, B, C, D, E, F, G, P> where G.Failure == P.Failure, G.Output == P.Output {
      return .init(a, b, c, d, e, f, g, other)
    }
  }
  /// A publisher created by applying the merge function to eight upstream Publishers.
  public struct Merge8<A: _Publisher, B: _Publisher, C: _Publisher, D: _Publisher, E: _Publisher, F: _Publisher, G: _Publisher, H: _Publisher>: _Publisher where A.Failure == B.Failure, A.Output == B.Output, B.Failure == C.Failure, B.Output == C.Output, C.Failure == D.Failure, C.Output == D.Output, D.Failure == E.Failure, D.Output == E.Output, E.Failure == F.Failure, E.Output == F.Output, F.Failure == G.Failure, F.Output == G.Output, G.Failure == H.Failure, G.Output == H.Output {
    public typealias Output = A.Output
    public typealias Failure = A.Failure
    public let a: A
    public let b: B
    public let c: C
    public let d: D
    public let e: E
    public let f: F
    public let g: G
    public let h: H
    public init(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H) {
      self.a = a
      self.b = b
      self.c = c
      self.d = d
      self.e = e
      self.f = f
      self.g = g
      self.h = h
    }
    public func receive<S: _Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
      let midstream = Channel.Merge(downstream: subscriber)
      a.subscribe(midstream)
      b.subscribe(midstream)
      c.subscribe(midstream)
      d.subscribe(midstream)
      e.subscribe(midstream)
      f.subscribe(midstream)
      g.subscribe(midstream)
      h.subscribe(midstream)
    }
  }
  public struct MergeMany<Upstream: _Publisher>: _Publisher {
    public typealias Output = Upstream.Output
    public typealias Failure = Upstream.Failure
    public let publishers: [Upstream]
    public init(_ upstream: Upstream...) {
      publishers = upstream
    }
    public init<S: Swift.Sequence>(_ upstream: S) where Upstream == S.Element {
      publishers = Array(upstream)
    }
    public func receive<S: _Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
      let midstream = Channel.Merge(downstream: subscriber)
      publishers.forEach { (publisher) in
        publisher.subscribe(midstream)
      }
    }
    public func merge(with other: Upstream) -> MergeMany<Upstream> {
      return .init(publishers + [other])
    }
  }
}
private extension _Publishers.Channel {
  class Merge<Downstream: _Subscriber>: _Publishers.Channel.Base<Downstream.Input, Downstream.Failure, Downstream> {
    var index: Int = 0
    var subscriptions: [_Subscription] = []
    override func receive(subscription: _Subscription) {
      if index > 0 {
        guard !super.isCancelled() else {
          return
        }
        subscriptions.append(subscription)
        subscription.request(.unlimited)
      }
      defer {
        index += 1
      }
      guard super.shouldReceive(subscription: subscription) else {
        return
      }
      downstream.receive(subscription: self)
    }
    override func receive(_ input: Input) -> _Subscribers.Demand {
      guard super.isSubscribedAndNotCompleted() else {
        return .none
      }
      return downstream.receive(input)
    }
    override func receive(completion: _Subscribers.Completion<Failure>) {
      guard super.shouldReceiveCompletion(completion) else {
        return
      }
      downstream.receive(completion: completion)
    }
    override var description: String {
      return "Merge"
    }
    override func cancel() {
      guard shouldCancel() else {
        return
      }
      guard let subscription = receivedSubscription() else {
        return
      }
      subscription.cancel()
      subscriptions.forEach { (subscription) in
        subscription.cancel()
      }
      event = .cancelled
    }
    override func request(_ demand: _Subscribers.Demand) {
      guard shouldRequest(demand) else {
        return
      }
      guard let subscription = receivedSubscription() else {
        return
      }
      subscription.request(demand)
      subscriptions.forEach { (subscription) in
        subscription.request(demand)
      }
    }
  }
}

extension _Publishers.Merge: Equatable where A: Equatable, B: Equatable {}
extension _Publishers.Merge3: Equatable where A: Equatable, B: Equatable, C: Equatable {}
extension _Publishers.Merge4: Equatable where A: Equatable, B: Equatable, C: Equatable, D: Equatable {}
extension _Publishers.Merge5: Equatable where A: Equatable, B: Equatable, C: Equatable, D: Equatable, E: Equatable {}
extension _Publishers.Merge6: Equatable where A: Equatable, B: Equatable, C: Equatable, D: Equatable, E: Equatable, F: Equatable {}
extension _Publishers.Merge7: Equatable where A: Equatable, B: Equatable, C: Equatable, D: Equatable, E: Equatable, F: Equatable, G: Equatable {}
extension _Publishers.Merge8: Equatable where A: Equatable, B: Equatable, C: Equatable, D: Equatable, E: Equatable, F: Equatable, G: Equatable, H: Equatable {}
extension _Publishers.MergeMany: Equatable where Upstream: Equatable {}
