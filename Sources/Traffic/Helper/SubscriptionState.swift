enum SubscriberEvent: Equatable, CustomStringConvertible {
  case pending
  case subscribed(subscription: _Subscription?, completion: Completion)
  case cancelled
  enum Completion: Equatable, CustomStringConvertible {
    case pending
    case fulfilled
    case rejected
    var description: String {
      return String(describing: self)
    }
  }
  var isSubscribed: Bool {
    guard case .subscribed = self else {
      return false
    }
    return true
  }
  var isCompleted: Bool {
    guard case let .subscribed(_, completion) = self else {
      return false
    }
    return completion != .pending
  }
  var isFinished: Bool {
    guard case let .subscribed(_, completion) = self else {
      return false
    }
    return completion == .fulfilled
  }
  var isFailed: Bool {
    guard case let .subscribed(_, completion) = self else {
      return false
    }
    return completion == .rejected
  }
  var isCancelled: Bool {
    return .cancelled == self
  }
  var embededSubscription: _Subscription? {
    guard case let .subscribed(subscription, _) = self else {
      return nil
    }
    return subscription
  }
  mutating func complete(_ isFinished: Bool) -> Bool {
    guard isSubscribed else {
      return false
    }
    self = .subscribed(subscription: embededSubscription, isFinished: isFinished)
    return true
  }
  static func subscribed(subscription: _Subscription?, isFinished: Bool) -> SubscriberEvent {
    return self.subscribed(subscription: subscription, completion: isFinished ? .fulfilled : .rejected)
  }
  static func == (lhs: SubscriberEvent, rhs: SubscriberEvent) -> Bool {
    switch (lhs, rhs) {
    case (.pending, .pending), (.cancelled, .cancelled):
      return true
    case let (.subscribed(lhs_subscription, lhs_completion), .subscribed(rhs_subscription, rhs_completion)):
      return lhs_subscription?.combineIdentifier == rhs_subscription?.combineIdentifier && lhs_completion == rhs_completion
    default:
      return false
    }
  }
  var description: String {
    switch self {
    case .cancelled: return "cancelled"
    case .pending: return "pending"
    case let .subscribed(subscription, completion): return "completion: \(completion), subscription: \(subscription.map(String.init(describing:)) ?? "nil")"
    }
  }
}
