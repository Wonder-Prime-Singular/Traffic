extension _Publisher {
  /// Subscribes to an additional publisher and publishes a tuple upon receiving output from either publisher.
  ///
  /// The combined publisher passes through any requests to *all* upstream Publishers. However, it still obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t `.unlimited`, it drops values from upstream Publishers. It implements this by using a buffer size of 1 for each upstream, and holds the most recent value in each buffer.
  /// All upstream publishers need to finish for this publisher to finsh. If an upstream publisher never publishes a value, this publisher never finishes.
  /// If any of the combined publishers terminates with a failure, this publisher also fails.
  /// - Parameters:
  ///   - other: Another publisher to combine with this one.
  /// - Returns: A publisher that receives and combines elements from this and another publisher.
  public func combineLatest<P: _Publisher>(_ other: P) -> _Publishers.CombineLatest<Self, P> where Self.Failure == P.Failure {
    return .init(self, other)
  }
  /// Subscribes to an additional publisher and invokes a closure upon receiving output from either publisher.
  ///
  /// The combined publisher passes through any requests to *all* upstream Publishers. However, it still obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t `.unlimited`, it drops values from upstream Publishers. It implements this by using a buffer size of 1 for each upstream, and holds the most recent value in each buffer.
  /// All upstream publishers need to finish for this publisher to finsh. If an upstream publisher never publishes a value, this publisher never finishes.
  /// If any of the combined publishers terminates with a failure, this publisher also fails.
  /// - Parameters:
  ///   - other: Another publisher to combine with this one.
  ///   - transform: A closure that receives the most recent value from each publisher and returns a new value to publish.
  /// - Returns: A publisher that receives and combines elements from this and another publisher.
  public func combineLatest<P: _Publisher, T>(_ other: P, _ transform: @escaping (Self.Output, P.Output) -> T) -> _Publishers.Map<_Publishers.CombineLatest<Self, P>, T> where Self.Failure == P.Failure {
    return .init(upstream: combineLatest(other), transform: transform)
  }
  /// Subscribes to two additional publishers and publishes a tuple upon receiving output from any of the Publishers.
  ///
  /// The combined publisher passes through any requests to *all* upstream Publishers. However, it still obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t `.unlimited`, it drops values from upstream Publishers. It implements this by using a buffer size of 1 for each upstream, and holds the most recent value in each buffer.
  /// All upstream publishers need to finish for this publisher to finish. If an upstream publisher never publishes a value, this publisher never finishes.
  /// If any of the combined publishers terminates with a failure, this publisher also fails.
  /// - Parameters:
  ///   - publisher1: A second publisher to combine with this one.
  ///   - publisher2: A third publisher to combine with this one.
  /// - Returns: A publisher that receives and combines elements from this publisher and two other Publishers.
  public func combineLatest<P: _Publisher, Q: _Publisher>(_ publisher1: P, _ publisher2: Q) -> _Publishers.CombineLatest3<Self, P, Q> where Self.Failure == P.Failure, P.Failure == Q.Failure {
    return .init(self, publisher1, publisher2)
  }
  /// Subscribes to two additional publishers and invokes a closure upon receiving output from any of the Publishers.
  ///
  /// The combined publisher passes through any requests to *all* upstream Publishers. However, it still obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t `.unlimited`, it drops values from upstream Publishers. It implements this by using a buffer size of 1 for each upstream, and holds the most recent value in each buffer.
  /// All upstream publishers need to finish for this publisher to finish. If an upstream publisher never publishes a value, this publisher never finishes.
  /// If any of the combined publishers terminates with a failure, this publisher also fails.
  /// - Parameters:
  ///   - publisher1: A second publisher to combine with this one.
  ///   - publisher2: A third publisher to combine with this one.
  ///   - transform: A closure that receives the most recent value from each publisher and returns a new value to publish.
  /// - Returns: A publisher that receives and combines elements from this publisher and two other Publishers.
  public func combineLatest<P: _Publisher, Q: _Publisher, T>(_ publisher1: P, _ publisher2: Q, _ transform: @escaping (Self.Output, P.Output, Q.Output) -> T) -> _Publishers.Map<_Publishers.CombineLatest3<Self, P, Q>, T> where Self.Failure == P.Failure, P.Failure == Q.Failure {
    return .init(upstream: combineLatest(publisher1, publisher2), transform: transform)
  }
  /// Subscribes to three additional publishers and publishes a tuple upon receiving output from any of the Publishers.
  ///
  /// The combined publisher passes through any requests to *all* upstream Publishers. However, it still obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t `.unlimited`, it drops values from upstream Publishers. It implements this by using a buffer size of 1 for each upstream, and holds the most recent value in each buffer.
  /// All upstream publishers need to finish for this publisher to finish. If an upstream publisher never publishes a value, this publisher never finishes.
  /// If any of the combined publishers terminates with a failure, this publisher also fails.
  /// - Parameters:
  ///   - publisher1: A second publisher to combine with this one.
  ///   - publisher2: A third publisher to combine with this one.
  ///   - publisher3: A fourth publisher to combine with this one.
  /// - Returns: A publisher that receives and combines elements from this publisher and three other Publishers.
  public func combineLatest<P: _Publisher, Q: _Publisher, R: _Publisher>(_ publisher1: P, _ publisher2: Q, _ publisher3: R) -> _Publishers.CombineLatest4<Self, P, Q, R> where Self.Failure == P.Failure, P.Failure == Q.Failure, Q.Failure == R.Failure {
    return .init(self, publisher1, publisher2, publisher3)
  }
  /// Subscribes to three additional publishers and invokes a closure upon receiving output from any of the Publishers.
  ///
  /// The combined publisher passes through any requests to *all* upstream Publishers. However, it still obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t `.unlimited`, it drops values from upstream Publishers. It implements this by using a buffer size of 1 for each upstream, and holds the most recent value in each buffer.
  /// All upstream publishers need to finish for this publisher to finish. If an upstream publisher never publishes a value, this publisher never finishes.
  /// If any of the combined publishers terminates with a failure, this publisher also fails.
  /// - Parameters:
  ///   - publisher1: A second publisher to combine with this one.
  ///   - publisher2: A third publisher to combine with this one.
  ///   - publisher3: A fourth publisher to combine with this one.
  ///   - transform: A closure that receives the most recent value from each publisher and returns a new value to publish.
  /// - Returns: A publisher that receives and combines elements from this publisher and three other Publishers.
  public func combineLatest<P: _Publisher, Q: _Publisher, R: _Publisher, T>(_ publisher1: P, _ publisher2: Q, _ publisher3: R, _ transform: @escaping (Self.Output, P.Output, Q.Output, R.Output) -> T) -> _Publishers.Map<_Publishers.CombineLatest4<Self, P, Q, R>, T> where Self.Failure == P.Failure, P.Failure == Q.Failure, Q.Failure == R.Failure {
    return .init(upstream: combineLatest(publisher1, publisher2, publisher3), transform: transform)
  }
}
extension _Publishers {
  /// A publisher that receives and combines the latest elements from two Publishers.
  public struct CombineLatest<A: _Publisher, B: _Publisher>: _Publisher where A.Failure == B.Failure {
    public typealias Output = (A.Output, B.Output)
    public typealias Failure = A.Failure
    public let a: A
    public let b: B
    public init(_ a: A, _ b: B) {
      self.a = a
      self.b = b
    }
    public func receive<S: _Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
      let s = Channel.MultiUpstreamBuilder(name: "CombineLatest", count: 2).buildCombineLatest(downstream: subscriber) { (inputs) in
        (inputs[0] as! A.Output, inputs[1] as! B.Output)
      }
      s.attach(to: a, at: 0)
      s.attach(to: b, at: 1)
    }
  }
  /// A publisher that receives and combines the latest elements from three Publishers.
  public struct CombineLatest3<A: _Publisher, B: _Publisher, C: _Publisher>: _Publisher where A.Failure == B.Failure, B.Failure == C.Failure {
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
      let s = Channel.MultiUpstreamBuilder(name: "CombineLatest3", count: 3).buildCombineLatest(downstream: subscriber) { (inputs) in
        (inputs[0] as! A.Output, inputs[1] as! B.Output, inputs[2] as! C.Output)
      }
      s.attach(to: a, at: 0)
      s.attach(to: b, at: 1)
      s.attach(to: c, at: 2)
    }
  }
  /// A publisher that receives and combines the latest elements from four Publishers.
  public struct CombineLatest4<A: _Publisher, B: _Publisher, C: _Publisher, D: _Publisher>: _Publisher where A.Failure == B.Failure, B.Failure == C.Failure, C.Failure == D.Failure {
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
      let s = Channel.MultiUpstreamBuilder(name: "CombineLatest4", count: 4).buildCombineLatest(downstream: subscriber) { (inputs) in
        (inputs[0] as! A.Output, inputs[1] as! B.Output, inputs[2] as! C.Output, inputs[3] as! D.Output)
      }
      s.attach(to: a, at: 0)
      s.attach(to: b, at: 1)
      s.attach(to: c, at: 2)
      s.attach(to: d, at: 3)
    }
  }
}
extension _Publishers.CombineLatest: Equatable where A: Equatable, B: Equatable {}
extension _Publishers.CombineLatest3: Equatable where A: Equatable, B: Equatable, C: Equatable {}
extension _Publishers.CombineLatest4: Equatable where A: Equatable, B: Equatable, C: Equatable, D: Equatable {}
