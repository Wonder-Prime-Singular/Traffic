extension _Publisher {
  /// Wraps this publisher with a type eraser.
  ///
  /// Use `eraseToAnyPublisher()` to expose an instance of AnyPublisher to the downstream subscriber, rather than this publisher’s actual type.
  public func eraseToAnyPublisher() -> _AnyPublisher<Self.Output, Self.Failure> {
    return .init(self)
  }
}
/// A type-erasing publisher.
///
/// Use `AnyPublisher` to wrap a publisher whose type has details you don’t want to expose to subscribers or other publishers.
public struct _AnyPublisher<Output, Failure: Swift.Error>: CustomStringConvertible {
  private let publisher: AnyPublisherBox<Output, Failure>
  public init<P: _Publisher>(_ publisher: P) where Output == P.Output, Failure == P.Failure {
    self.publisher = EmbeddedPublisher(publisher)
  }
  public var description: String {
    return publisher.description
  }
}
extension _AnyPublisher: _Publisher {
  public func receive<S: _Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
    publisher.receive(subscriber: subscriber)
  }
}
