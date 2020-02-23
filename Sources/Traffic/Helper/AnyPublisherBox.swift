class EmbeddedPublisher<P: _Publisher>: AnyPublisherBox<P.Output, P.Failure> {
  private let publisher: P
  internal init(_ publisher: P) {
    self.publisher = publisher
  }
  override func receive<S: _Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
    publisher.receive(subscriber: subscriber)
  }
  public override var description: String {
    return "\(type(of: publisher))"
  }
}
class AnyPublisherBox<Output, Failure: Swift.Error>: _Publisher, CustomStringConvertible {
  func receive<S: _Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
    traffic_abstract_method()
  }
  public var description: String {
    traffic_abstract_method()
  }
}
