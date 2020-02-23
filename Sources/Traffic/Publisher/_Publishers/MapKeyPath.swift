extension _Publisher {
  /// Returns a publisher that publishes the value of a key path.
  ///
  /// - Parameter keyPath: The key path of a property on `Output`
  /// - Returns: A publisher that publishes the value of the key path.
  public func map<T>(_ keyPath: KeyPath<Self.Output, T>) -> _Publishers.MapKeyPath<Self, T> {
    return .init(upstream: self, keyPath: keyPath)
  }
  /// Returns a publisher that publishes the values of two key paths as a tuple.
  ///
  /// - Parameters:
  ///   - keyPath0: The key path of a property on `Output`
  ///   - keyPath1: The key path of another property on `Output`
  /// - Returns: A publisher that publishes the values of two key paths as a tuple.
  public func map<T0, T1>(_ keyPath0: KeyPath<Self.Output, T0>, _ keyPath1: KeyPath<Self.Output, T1>) -> _Publishers.MapKeyPath2<Self, T0, T1> {
    return .init(upstream: self, keyPath0: keyPath0, keyPath1: keyPath1)
  }
  /// Returns a publisher that publishes the values of three key paths as a tuple.
  ///
  /// - Parameters:
  ///   - keyPath0: The key path of a property on `Output`
  ///   - keyPath1: The key path of another property on `Output`
  ///   - keyPath2: The key path of a third  property on `Output`
  /// - Returns: A publisher that publishes the values of three key paths as a tuple.
  public func map<T0, T1, T2>(_ keyPath0: KeyPath<Self.Output, T0>, _ keyPath1: KeyPath<Self.Output, T1>, _ keyPath2: KeyPath<Self.Output, T2>) -> _Publishers.MapKeyPath3<Self, T0, T1, T2> {
    return .init(upstream: self, keyPath0: keyPath0, keyPath1: keyPath1, keyPath2: keyPath2)
  }
}
extension _Publishers {
  /// A publisher that publishes the value of a key path.
  public struct MapKeyPath<Upstream: _Publisher, Output>: _Publisher {
    public typealias Failure = Upstream.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// The key path of a property to publish.
    public let keyPath: KeyPath<Upstream.Output, Output>
    public init(upstream: Upstream, keyPath: KeyPath<Upstream.Output, Output>) {
      self.upstream = upstream
      self.keyPath = keyPath
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.Anonymous<Upstream.Output, Upstream.Failure, Downstream>(label: "MapKeyPath", downstream: subscriber, receiveSubscription: { (channel, subscription) in
        channel.downstream.receive(subscription: subscription)
      }, receiveValue: { (channel, value) in
        channel.downstream.receive(value[keyPath: self.keyPath])
      }, receiveCompletion: { (channel, completion) in
        channel.downstream.receive(completion: completion)
      })
      upstream.subscribe(midstream)
    }
  }
  /// A publisher that publishes the values of two key paths as a tuple.
  public struct MapKeyPath2<Upstream: _Publisher, Output0, Output1>: _Publisher {
    public typealias Output = (Output0, Output1)
    public typealias Failure = Upstream.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// The key path of a property to publish.
    public let keyPath0: KeyPath<Upstream.Output, Output0>
    /// The key path of a second property to publish.
    public let keyPath1: KeyPath<Upstream.Output, Output1>
    public init(upstream: Upstream, keyPath0: KeyPath<Upstream.Output, Output0>, keyPath1: KeyPath<Upstream.Output, Output1>) {
      self.upstream = upstream
      self.keyPath0 = keyPath0
      self.keyPath1 = keyPath1
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.Anonymous<Upstream.Output, Upstream.Failure, Downstream>(label: "MapKeyPath2", downstream: subscriber, receiveSubscription: { (channel, subscription) in
        channel.downstream.receive(subscription: subscription)
      }, receiveValue: { (channel, value) in
        channel.downstream.receive((value[keyPath: self.keyPath0], value[keyPath: self.keyPath1]))
      }, receiveCompletion: { (channel, completion) in
        channel.downstream.receive(completion: completion)
      })
      upstream.subscribe(midstream)
    }
  }
  /// A publisher that publishes the values of three key paths as a tuple.
  public struct MapKeyPath3<Upstream: _Publisher, Output0, Output1, Output2>: _Publisher {
    public typealias Output = (Output0, Output1, Output2)
    public typealias Failure = Upstream.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// The key path of a property to publish.
    public let keyPath0: KeyPath<Upstream.Output, Output0>
    /// The key path of a second property to publish.
    public let keyPath1: KeyPath<Upstream.Output, Output1>
    /// The key path of a third property to publish.
    public let keyPath2: KeyPath<Upstream.Output, Output2>
    public init(upstream: Upstream, keyPath0: KeyPath<Upstream.Output, Output0>, keyPath1: KeyPath<Upstream.Output, Output1>, keyPath2: KeyPath<Upstream.Output, Output2>) {
      self.upstream = upstream
      self.keyPath0 = keyPath0
      self.keyPath1 = keyPath1
      self.keyPath2 = keyPath2
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let midstream = Channel.Anonymous<Upstream.Output, Upstream.Failure, Downstream>(label: "MapKeyPath3", downstream: subscriber, receiveSubscription: { (channel, subscription) in
        channel.downstream.receive(subscription: subscription)
      }, receiveValue: { (channel, value) in
        channel.downstream.receive((value[keyPath: self.keyPath0], value[keyPath: self.keyPath1], value[keyPath: self.keyPath2]))
      }, receiveCompletion: { (channel, completion) in
        channel.downstream.receive(completion: completion)
      })
      upstream.subscribe(midstream)
    }
  }
}
