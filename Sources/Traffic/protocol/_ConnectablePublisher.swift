public protocol _ConnectablePublisher: _Publisher {
  /// Connects to the publisher and returns a `Cancellable` instance with which to cancel publishing.
  ///
  /// - Returns: A `Cancellable` instance that can be used to cancel publishing.
  func connect() -> _Cancellable
}
