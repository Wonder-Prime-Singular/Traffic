/// The default publisher of an `ObservableObject`.
public final class ObservableObjectPublisher: _Publisher {
  public typealias Output = Void
  public typealias Failure = Never
  private let subject: _PassthroughSubject<Void, Never>
  public init() {
    subject = .init()
  }
  public func receive<S: _Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
    subject.subscribe(subscriber)
  }
  public func send() {
    subject.send()
  }
}
