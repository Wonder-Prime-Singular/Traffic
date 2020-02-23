/// A publisher that never publishes any values, and optionally finishes immediately.
///
/// You can create a ”Never” publisher — one which never sends values and never finishes or fails — with the initializer `Empty(completeImmediately: false)`.
public struct _Empty<Output, Failure: Swift.Error>: _Publisher, Equatable {
  /// A Boolean value that indicates whether the publisher immediately sends a completion.
  ///
  /// If `true`, the publisher finishes immediately after sending a subscription to the subscriber. If `false`, it never completes.
  public let completeImmediately: Bool
  /// Creates an empty publisher.
  ///
  /// - Parameter completeImmediately: A Boolean value that indicates whether the publisher should immediately finish.
  public init(completeImmediately: Bool = true) {
    self.completeImmediately = completeImmediately
  }
  /// Creates an empty publisher with the given completion behavior and output and failure types.
  ///
  /// Use this initializer to connect the empty publisher to subscribers or other publishers that have specific output and failure types.
  /// - Parameters:
  ///   - completeImmediately: A Boolean value that indicates whether the publisher should immediately finish.
  ///   - outputType: The output type exposed by this publisher.
  ///   - failureType: The failure type exposed by this publisher.
  public init(completeImmediately: Bool = true, outputType: Output.Type, failureType: Failure.Type) {
    self.completeImmediately = completeImmediately
  }
  public func receive<S: _Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
    subscriber.receive(subscription: _Subscriptions.empty)
    if completeImmediately {
      subscriber.receive(completion: .finished)
    }
  }
}
