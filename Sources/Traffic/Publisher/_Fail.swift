/// A publisher that immediately terminates with the specified error.
public struct _Fail<Output, Failure: Swift.Error>: _Publisher {
  /// The failure to send when terminating the publisher.
  public let error: Failure
  /// Creates a publisher that immediately terminates with the specified failure.
  ///
  /// - Parameter error: The failure to send when terminating the publisher.
  public init(error: Failure) {
    self.error = error
  }
  /// Creates publisher with the given output type, that immediately terminates with the specified failure.
  ///
  /// Use this initializer to create a `Fail` publisher that can work with subscribers or publishers that expect a given output type.
  /// - Parameters:
  ///   - outputType: The output type exposed by this publisher.
  ///   - failure: The failure to send when terminating the publisher.
  public init(outputType: Output.Type, failure: Failure) {
    error = failure
  }
  public func receive<S: _Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
    subscriber.receive(subscription: _Subscriptions.empty)
    subscriber.receive(completion: .failure(error))
  }
}
extension _Fail: Equatable where Failure: Equatable {
}
