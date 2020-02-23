extension _Publishers {
  @usableFromInline
  enum Channel {
    @usableFromInline
    class Base<UpstreamOutput, UpstreamFailure: Swift.Error, Downstream: _Subscriber>: _Subscriber, _Subscription, CustomStringConvertible, CustomReflectable, CustomPlaygroundDisplayConvertible {
      public typealias Input = UpstreamOutput
      public typealias Failure = UpstreamFailure
      var downstream: Downstream!
      var event: SubscriberEvent = .pending
      var demand: _Subscribers.Demand = 0
      @usableFromInline
      internal init(downstream: Downstream?) {
        self.downstream = downstream
      }
      @usableFromInline
      func isCompleted() -> Bool {
        return event.isSubscribed && event.isCompleted
      }
      @usableFromInline
      func isSubscribed() -> Bool {
        return event.isSubscribed
      }
      @usableFromInline
      func isCancelled() -> Bool {
        return event.isCancelled
      }
      @usableFromInline
      func receivedSubscription() -> _Subscription? {
        return event.embededSubscription
      }
      @usableFromInline
      func isSubscribedAndNotCompleted() -> Bool {
        return isSubscribed() && !isCompleted()
      }
      @usableFromInline
      func shouldReceive(subscription: _Subscription) -> Bool {
        guard .pending == event else {
          return false
        }
        self.event = .subscribed(subscription: subscription, completion: .pending)
        return true
      }
      @usableFromInline
      func shouldReceiveCompletion<Failure: Error>(_ completion: _Subscribers.Completion<Failure>) -> Bool {
        guard isSubscribedAndNotCompleted() else {
          return false
        }
        guard event.complete(completion.isFinished) else {
          return false
        }
        return true
      }
      @usableFromInline
      func shouldCancel() -> Bool {
        guard isSubscribed() else {
          return false
        }
        return true
      }
      @usableFromInline
      func shouldRequest(_ demand: _Subscribers.Demand) -> Bool {
        guard isSubscribed() else {
          return false
        }
        self.demand += demand
        return true
      }
      @usableFromInline
      func receive(subscription: _Subscription) {
        guard shouldReceive(subscription: subscription) else {
          return
        }
        traffic_abstract_method()
      }
      @usableFromInline
      func receive(_ input: Input) -> _Subscribers.Demand {
        guard isSubscribedAndNotCompleted() else {
          return .none
        }
        traffic_abstract_method()
      }
      @usableFromInline
      func receive(completion: _Subscribers.Completion<Failure>) {
        guard shouldReceiveCompletion(completion) else {
          return
        }
        traffic_abstract_method()
      }
      @usableFromInline
      final func receive(typeErasedCompletion completion: _Subscribers.Completion<Swift.Error>) {
        self.receive(completion: completion as! _Subscribers.Completion<Failure>)
      }
      @usableFromInline
      var combineIdentifier: CombineIdentifier {
        return downstream?.combineIdentifier ?? CombineIdentifier(self)
      }
      @usableFromInline
      func cancel() {
        guard shouldCancel() else {
          return
        }
        guard let subscription = receivedSubscription() else {
          return
        }
        subscription.cancel()
        event = .cancelled
      }
      @usableFromInline
      func request(_ demand: _Subscribers.Demand) {
        guard shouldRequest(demand) else {
          return
        }
        guard let subscription = receivedSubscription() else {
          return
        }
        subscription.request(demand)
      }
      @usableFromInline
      var description: String {
        traffic_abstract_method()
      }
      @usableFromInline
      var customMirror: Mirror {
        return description.customMirror
      }
      @usableFromInline
      var playgroundDescription: Any {
        return description
      }
    }
    @usableFromInline
    class TransformBase<UpstreamOutput, UpstreamFailure: Swift.Error, Downstream: _Subscriber>: Base<UpstreamOutput, UpstreamFailure, Downstream> {
      var hasThrown: Bool = false
      @usableFromInline
      final override func receive(subscription: _Subscription) {
        guard shouldReceive(subscription: subscription) else {
          return
        }
        downstream.receive(subscription: self)
      }
      @usableFromInline
      final override func receive(_ input: Input) -> _Subscribers.Demand {
        guard isSubscribedAndNotCompleted() else {
          return .none
        }
        do {
          return try transformInput(input).map(downstream.receive(_:)) ?? .none
        } catch {
          hasThrown = true
          super.receive(typeErasedCompletion: .failure(error))
          return .none
        }
      }
      @usableFromInline
      final override func receive(completion: _Subscribers.Completion<Failure>) {
        guard shouldReceiveCompletion(completion) else {
          return
        }
        if !hasThrown {
          willComplete(completion: completion)
        }
        downstream.receive(completion: completion.mapError(transform: self.transformError(_:)))
      }
      @usableFromInline
      func transformInput(_ input: Input) throws -> Downstream.Input? {
        traffic_abstract_method()
      }
      @usableFromInline
      func transformError(_ error: Failure) -> Downstream.Failure {
        return error as! Downstream.Failure
      }
      @usableFromInline
      func willComplete(completion: _Subscribers.Completion<Failure>) {

      }
    }
    @usableFromInline
    class FilterBase<UpstreamFailure: Swift.Error, Downstream: _Subscriber>: TransformBase<Downstream.Input, UpstreamFailure, Downstream> {
      @usableFromInline
      final override func transformInput(_ input: Input) throws  -> Downstream.Input? {
        if try filterInput(input) {
          return input
        }
        return nil
      }
      @usableFromInline
      func filterInput(_ input: Input) throws -> Bool {
        traffic_abstract_method()
      }
    }
    @usableFromInline
    final class Anonymous<UpstreamOutput, UpstreamFailure: Swift.Error, Downstream: _Subscriber>: Base<UpstreamOutput, UpstreamFailure, Downstream> {
      public typealias Class = Anonymous<Input, Failure, Downstream>
      internal let descriptionClosure: () -> String
      internal let receiveSubscription: ((Class, _Subscription) -> Void)?
      internal let receiveValue: ((Class, Input) -> _Subscribers.Demand)?
      internal let receiveCompletion: ((Class, _Subscribers.Completion<Failure>) -> Void)?
      @usableFromInline
      internal init(label: @escaping @autoclosure () -> String, downstream: Downstream, receiveSubscription: ((Class, _Subscription) -> Void)? = nil, receiveValue: ((Class, Input) -> _Subscribers.Demand)? = nil, receiveCompletion: ((Class, _Subscribers.Completion<Failure>) -> Void)? = nil) {
        self.receiveSubscription = receiveSubscription
        self.receiveValue = receiveValue
        self.receiveCompletion = receiveCompletion
        self.descriptionClosure = label
        super.init(downstream: downstream)
      }
      @usableFromInline
      internal convenience init(label: @escaping @autoclosure () -> String, downstream: Downstream, receiveSubscription: ((Class, _Subscription) -> Void)? = nil, receiveThrowableValue: ((Class, Input) throws -> _Subscribers.Demand)? = nil, receiveCompletion: ((Class, _Subscribers.Completion<Downstream.Failure>) -> Void)? = nil) {
        let receiveCompletion: ((Class, _Subscribers.Completion<Failure>) -> Void)? = receiveCompletion as? (Class, _Subscribers.Completion<Failure>) -> Void
        self.init(label: label(), downstream: downstream, receiveSubscription: receiveSubscription, receiveValue: { (channel, value) in
          do {
            return try receiveThrowableValue?(channel, value) ?? .none
          } catch {
            receiveCompletion?(channel, .failure(error as! Failure))
            return .none
          }
        }, receiveCompletion: { (channel, completion) in
          receiveCompletion?(channel, completion)
        })
      }
      @usableFromInline
      override func receive(subscription: _Subscription) {
        guard shouldReceive(subscription: subscription) else {
          return
        }
        receiveSubscription?(self, self)
      }
      @usableFromInline
      override func receive(_ input: Input) -> _Subscribers.Demand {
        guard isSubscribedAndNotCompleted() else {
          return .none
        }
        return receiveValue?(self, input) ?? .none
      }
      @usableFromInline
      override func receive(completion: _Subscribers.Completion<Failure>) {
        guard shouldReceiveCompletion(completion) else {
          return
        }
        receiveCompletion?(self, completion)
      }
      @usableFromInline
      override var description: String {
        return descriptionClosure()
      }
    }
  }
}
