extension _Publisher {
  /// Attaches the specified subscriber to this publisher.
  ///
  /// Always call this function instead of `receive(subscriber:)`.
  /// Adopters of `Publisher` must implement `receive(subscriber:)`. The implementation of `subscribe(_:)` in this extension calls through to `receive(subscriber:)`.
  /// - SeeAlso: `receive(subscriber:)`
  /// - Parameters:
  ///     - subscriber: The subscriber to attach to this `Publisher`. After attaching, the subscriber can start to receive values.
  public func subscribe<S: _Subscriber>(_ subscriber: S) where Self.Failure == S.Failure, Self.Output == S.Input {
    receive(subscriber: subscriber)
  }
}
