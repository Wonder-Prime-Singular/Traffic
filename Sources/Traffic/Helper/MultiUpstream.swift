extension _Publishers.Channel {
  final class MultiUpstream<AnyInput, Downstream: _Subscriber> {
    let name: String
    var inputs: [AnyInput]
    let count: Int
    var upstreamSubscriptions: [_Subscription?] = []
    var downstream: Downstream
    let lock: Locking = RecursiveLock()
    let receiveValue: (_ value: Any, _ index: Int, _ outputs: inout [AnyInput], _ downstream: Downstream) -> Void

    internal init(name: String, downstream: Downstream, placeholder: AnyInput, count: Int, receiveValue: @escaping (_ value: Any, _ index: Int, _ outputs: inout [AnyInput], _ subscriber: Downstream) -> Void) {
      self.name = name
      self.downstream = downstream
      self.inputs = [AnyInput](repeating: placeholder, count: count)
      self.count = count
      self.upstreamSubscriptions = [_Subscription?](repeating: nil, count: count)
      self.receiveValue = receiveValue
    }

    func attach<Upstream: _Publisher>(to upstream: Upstream, at index: Int) where Upstream.Failure == Downstream.Failure {
      precondition(index < count)
      let midstream = MultiUpstreamSubChannel<Upstream.Output>(channel: self, index: index)
      upstream.subscribe(midstream)
    }

    func receiveSingle(subscription: _Subscription, at index: Int) {
      lock.withLock {
        guard nil == upstreamSubscriptions[index] else {
          return
        }
        upstreamSubscriptions[index] = subscription
        guard upstreamSubscriptions.filter({ $0 == nil }).isEmpty else {
          return
        }
        let derived = DerivedSubscription(name: name, subscriptions: upstreamSubscriptions.compactMap({ $0 }))
        downstream.receive(subscription: derived)
        upstreamSubscriptions.removeAll()
      }
    }

    func receiveSingle(_ input: Any, at index: Int) -> _Subscribers.Demand {
      return lock.withLock {
        receiveValue(input, index, &inputs, downstream)
        return .none
      }
    }

    func receiveSingle(completion: _Subscribers.Completion<Downstream.Failure>, at index: Int) {
      lock.withLock {
        downstream.receive(completion: completion)
      }
    }
    struct MultiUpstreamSubChannel<Input>: _Subscriber {
      typealias Failure = Downstream.Failure
      typealias ChannelClass = MultiUpstream
      private weak var unretainedChannel : ChannelClass?
      private var retainedChannel : ChannelClass?
      private var channel: ChannelClass? {
        return unretainedChannel ?? retainedChannel
      }
      let index: Int
      init(channel: ChannelClass, index: Int) {
        self.index = index
        if index == 0 {
          retainedChannel = channel
        } else {
          unretainedChannel = channel
        }
      }
      func receive(subscription: _Subscription) {
        channel?.receiveSingle(subscription: subscription, at: index)
      }
      func receive(_ input: Input) -> _Subscribers.Demand {
        return channel?.receiveSingle(input, at: index) ?? .none
      }
      func receive(completion: _Subscribers.Completion<Failure>) {
        channel?.receiveSingle(completion: completion, at: index)
      }
      var combineIdentifier: CombineIdentifier {
        return channel?.downstream.combineIdentifier ?? .init()
      }
    }
  }
  private class DerivedSubscription: _Subscription, CustomStringConvertible {
    let name: String
    let subscriptions: [_Subscription]
    public init(name: String, subscriptions: [_Subscription]) {
      self.name = name
      self.subscriptions = subscriptions
    }
    func request(_ demand: _Subscribers.Demand) {
      subscriptions.forEach({ (subscription) in
        subscription.request(demand)
      })
    }
    func cancel() {
      subscriptions.forEach({ (subscription) in
        subscription.cancel()
      })
    }
    var combineIdentifier: CombineIdentifier = .init()
    var description: String {
      return name
    }
  }
  struct MultiUpstreamBuilder {
    let name: String
    let count: Int
    func buildCombineLatest<Downstream: _Subscriber>(downstream: Downstream, transform: @escaping ([Any]) -> Downstream.Input) -> MultiUpstream<Optional<Any>, Downstream> {
      return MultiUpstream(name: name, downstream: downstream, placeholder: Optional<Any>.none, count: count) { (value, index, outputs, downstream) in
        outputs[index] = value
        guard outputs.first(where: { (output) in output == nil }) == nil else {
          return
        }
        _ = downstream.receive(transform(outputs.map { (output) in output! }))
      }
    }
    func buildZip<Downstream: _Subscriber>(downstream: Downstream, transform: @escaping ([Any]) -> Downstream.Input) -> MultiUpstream<[Any], Downstream> {
      let count = self.count
      return MultiUpstream(name: name, downstream: downstream, placeholder: [Any](), count: count)  { (value, index, outputs, downstream) in
        outputs[index].append(value)
        guard outputs.first(where: { (branch) in branch.isEmpty }) == nil else {
          return
        }
        var inputs: [Any] = []
        for index in 0 ..< count {
          inputs.append(outputs[index].removeFirst())
        }
        _ = downstream.receive(transform(inputs))
      }
    }
  }
}
