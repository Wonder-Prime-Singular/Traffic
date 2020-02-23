extension _Publisher {
  /// Combine elements from another publisher and deliver pairs of elements as tuples.
  ///
  /// The returned publisher waits until both publishers have emitted an event, then delivers the oldest unconsumed event from each publisher together as a tuple to the subscriber.
  /// For example, if publisher `P1` emits elements `a` and `b`, and publisher `P2` emits event `c`, the zip publisher emits the tuple `(a, c)`. It won’t emit a tuple with event `b` until `P2` emits another event.
  /// If either upstream publisher finishes successfuly or fails with an error, the zipped publisher does the same.
  ///
  /// - Parameter other: Another publisher.
  /// - Returns: A publisher that emits pairs of elements from the upstream publishers as tuples.
  public func zip<P: _Publisher>(_ other: P) -> _Publishers.Zip<Self, P> where Failure == P.Failure {
    return .init(self, other)
  }
  /// Combine elements from another publisher and deliver a transformed output.
  ///
  /// The returned publisher waits until both publishers have emitted an event, then delivers the oldest unconsumed event from each publisher together as a tuple to the subscriber.
  /// For example, if publisher `P1` emits elements `a` and `b`, and publisher `P2` emits event `c`, the zip publisher emits the tuple `(a, c)`. It won’t emit a tuple with event `b` until `P2` emits another event.
  /// If either upstream publisher finishes successfuly or fails with an error, the zipped publisher does the same.
  ///
  /// - Parameter other: Another publisher.
  ///   - transform: A closure that receives the most recent value from each publisher and returns a new value to publish.
  /// - Returns: A publisher that emits pairs of elements from the upstream publishers as tuples.
  public func zip<P: _Publisher, T>(_ other: P, _ transform: @escaping (Self.Output, P.Output) -> T) -> _Publishers.Map<_Publishers.Zip<Self, P>, T> where Self.Failure == P.Failure {
    return zip(other).map(transform)
  }
  /// Combine elements from two other publishers and deliver groups of elements as tuples.
  ///
  /// The returned publisher waits until all three publishers have emitted an event, then delivers the oldest unconsumed event from each publisher as a tuple to the subscriber.
  /// For example, if publisher `P1` emits elements `a` and `b`, and publisher `P2` emits elements `c` and `d`, and publisher `P3` emits the event `e`, the zip publisher emits the tuple `(a, c, e)`. It won’t emit a tuple with elements `b` or `d` until `P3` emits another event.
  /// If any upstream publisher finishes successfuly or fails with an error, the zipped publisher does the same.
  ///
  /// - Parameters:
  ///   - publisher1: A second publisher.
  ///   - publisher2: A third publisher.
  /// - Returns: A publisher that emits groups of elements from the upstream publishers as tuples.
  public func zip<P: _Publisher, Q: _Publisher>(_ publisher1: P, _ publisher2: Q) -> _Publishers.Zip3<Self, P, Q> where Self.Failure == P.Failure, P.Failure == Q.Failure {
    return .init(self, publisher1, publisher2)
  }
  /// Combine elements from two other publishers and deliver a transformed output.
  ///
  /// The returned publisher waits until all three publishers have emitted an event, then delivers the oldest unconsumed event from each publisher as a tuple to the subscriber.
  /// For example, if publisher `P1` emits elements `a` and `b`, and publisher `P2` emits elements `c` and `d`, and publisher `P3` emits the event `e`, the zip publisher emits the tuple `(a, c, e)`. It won’t emit a tuple with elements `b` or `d` until `P3` emits another event.
  /// If any upstream publisher finishes successfuly or fails with an error, the zipped publisher does the same.
  ///
  /// - Parameters:
  ///   - publisher1: A second publisher.
  ///   - publisher2: A third publisher.
  ///   - transform: A closure that receives the most recent value from each publisher and returns a new value to publish.
  /// - Returns: A publisher that emits groups of elements from the upstream publishers as tuples.
  public func zip<P: _Publisher, Q: _Publisher, T>(_ publisher1: P, _ publisher2: Q, _ transform: @escaping (Self.Output, P.Output, Q.Output) -> T) -> _Publishers.Map<_Publishers.Zip3<Self, P, Q>, T> where Self.Failure == P.Failure, P.Failure == Q.Failure {
    return zip(publisher1, publisher2).map(transform)
  }
  /// Combine elements from three other publishers and deliver groups of elements as tuples.
  ///
  /// The returned publisher waits until all four publishers have emitted an event, then delivers the oldest unconsumed event from each publisher as a tuple to the subscriber.
  /// For example, if publisher `P1` emits elements `a` and `b`, and publisher `P2` emits elements `c` and `d`, and publisher `P3` emits the elements `e` and `f`, and publisher `P4` emits the event `g`, the zip publisher emits the tuple `(a, c, e, g)`. It won’t emit a tuple with elements `b`, `d`, or `f` until `P4` emits another event.
  /// If any upstream publisher finishes successfuly or fails with an error, the zipped publisher does the same.
  ///
  /// - Parameters:
  ///   - publisher1: A second publisher.
  ///   - publisher2: A third publisher.
  ///   - publisher3: A fourth publisher.
  /// - Returns: A publisher that emits groups of elements from the upstream publishers as tuples.
  public func zip<P: _Publisher, Q: _Publisher, R: _Publisher>(_ publisher1: P, _ publisher2: Q, _ publisher3: R) -> _Publishers.Zip4<Self, P, Q, R> where Self.Failure == P.Failure, P.Failure == Q.Failure, Q.Failure == R.Failure {
    return .init(self, publisher1, publisher2, publisher3)
  }
  /// Combine elements from three other publishers and deliver a transformed output.
  ///
  /// The returned publisher waits until all four publishers have emitted an event, then delivers the oldest unconsumed event from each publisher as a tuple to the subscriber.
  /// For example, if publisher `P1` emits elements `a` and `b`, and publisher `P2` emits elements `c` and `d`, and publisher `P3` emits the elements `e` and `f`, and publisher `P4` emits the event `g`, the zip publisher emits the tuple `(a, c, e, g)`. It won’t emit a tuple with elements `b`, `d`, or `f` until `P4` emits another event.
  /// If any upstream publisher finishes successfuly or fails with an error, the zipped publisher does the same.
  ///
  /// - Parameters:
  ///   - publisher1: A second publisher.
  ///   - publisher2: A third publisher.
  ///   - publisher3: A fourth publisher.
  ///   - transform: A closure that receives the most recent value from each publisher and returns a new value to publish.
  /// - Returns: A publisher that emits groups of elements from the upstream publishers as tuples.
  public func zip<P: _Publisher, Q: _Publisher, R: _Publisher, T>(_ publisher1: P, _ publisher2: Q, _ publisher3: R, _ transform: @escaping (Self.Output, P.Output, Q.Output, R.Output) -> T) -> _Publishers.Map<_Publishers.Zip4<Self, P, Q, R>, T> where Self.Failure == P.Failure, P.Failure == Q.Failure, Q.Failure == R.Failure {
    return zip(publisher1, publisher2, publisher3).map(transform)
  }
}
extension _Publishers {
  /// A publisher created by applying the zip function to two upstream publishers.
  public struct Zip<A: _Publisher, B: _Publisher>: _Publisher where A.Failure == B.Failure {
    public typealias Output = (A.Output, B.Output)
    public typealias Failure = A.Failure
    public let a: A
    public let b: B
    public init(_ a: A, _ b: B) {
      self.a = a
      self.b = b
    }
    public func receive<S: _Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
      let s = Channel.MultiUpstreamBuilder(name: "Zip", count: 2).buildZip(downstream: subscriber) { (inputs) in
        (inputs[0] as! A.Output, inputs[1] as! B.Output)
      }
      s.attach(to: a, at: 0)
      s.attach(to: b, at: 1)
    }
  }
  /// A publisher created by applying the zip function to three upstream Publishers.
  public struct Zip3<A: _Publisher, B: _Publisher, C: _Publisher>: _Publisher where A.Failure == B.Failure, B.Failure == C.Failure {
    public typealias Output = (A.Output, B.Output, C.Output)
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
      let s = Channel.MultiUpstreamBuilder(name: "Zip3", count: 3).buildZip(downstream: subscriber) { (inputs) in
        (inputs[0] as! A.Output, inputs[1] as! B.Output, inputs[2] as! C.Output)
      }
      s.attach(to: a, at: 0)
      s.attach(to: b, at: 1)
      s.attach(to: c, at: 2)
    }
  }
  /// A publisher created by applying the zip function to four upstream Publishers.
  public struct Zip4<A: _Publisher, B: _Publisher, C: _Publisher, D: _Publisher>: _Publisher where A.Failure == B.Failure, B.Failure == C.Failure, C.Failure == D.Failure {
    public typealias Output = (A.Output, B.Output, C.Output, D.Output)
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
      let s = Channel.MultiUpstreamBuilder(name: "Zip4", count: 4).buildZip(downstream: subscriber) { (inputs) in
        (inputs[0] as! A.Output, inputs[1] as! B.Output, inputs[2] as! C.Output, inputs[3] as! D.Output)
      }
      s.attach(to: a, at: 0)
      s.attach(to: b, at: 1)
      s.attach(to: c, at: 2)
      s.attach(to: d, at: 3)
    }
  }
}
extension _Publishers.Zip: Equatable where A: Equatable, B: Equatable {}
extension _Publishers.Zip3: Equatable where A: Equatable, B: Equatable, C: Equatable {}
extension _Publishers.Zip4: Equatable where A: Equatable, B: Equatable, C: Equatable, D: Equatable {}
