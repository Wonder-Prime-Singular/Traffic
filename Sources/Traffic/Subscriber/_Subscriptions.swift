public enum _Subscriptions {}
extension _Subscriptions {
  /// Returns the 'empty' subscription.
  ///
  /// Use the empty subscription when you need a `Subscription` that ignores requests and cancellation.
  public static let empty: _Subscription = {
    return EmptySubscription()
  }()
  private class EmptySubscription: _Subscription, CustomStringConvertible {
    func request(_ demand: _Subscribers.Demand) {

    }
    func cancel() {

    }
    let combineIdentifier: CombineIdentifier = .init()
    let description: String = "Empty"
  }
}
