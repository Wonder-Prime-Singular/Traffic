extension _Publisher {
  /// Applies a closure to create a subject that delivers elements to subscribers.
  ///
  /// Use a multicast publisher when you have multiple downstream subscribers, but you want upstream publishers to only process one `receive(_:)` call per event.
  /// In contrast with `multicast(subject:)`, this method produces a publisher that creates a separate Subject for each subscriber.
  /// - Parameter createSubject: A closure to create a new Subject each time a subscriber attaches to the multicast publisher.
  public func multicast<S: _Subject>(_ createSubject: @escaping () -> S) -> _Publishers.Multicast<Self, S> where Self.Failure == S.Failure, Self.Output == S.Output {
    return .init(upstream: self, createSubject: createSubject)
  }
  /// Provides a subject to deliver elements to multiple subscribers.
  ///
  /// Use a multicast publisher when you have multiple downstream subscribers, but you want upstream publishers to only process one `receive(_:)` call per event.
  /// In contrast with `multicast(_:)`, this method produces a publisher shares the provided Subject among all the downstream subscribers.
  /// - Parameter subject: A subject to deliver elements to downstream subscribers.
  public func multicast<S: _Subject>(subject: S) -> _Publishers.Multicast<Self, S> where Self.Failure == S.Failure, Self.Output == S.Output {
    return .init(upstream: self, createSubject: { subject })
  }
}
extension _Publishers {
  /// A publisher that uses a subject to deliver elements to multiple subscribers.
  public final class Multicast<Upstream: _Publisher, SubjectType: _Subject>: _ConnectablePublisher where Upstream.Failure == SubjectType.Failure, Upstream.Output == SubjectType.Output {
    public typealias Output = Upstream.Output
    public typealias Failure = Upstream.Failure
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    /// A closure to create a new Subject each time a subscriber attaches to the multicast publisher.
    public let createSubject: () -> SubjectType
    private var connection: _AnyCancellable?
    private var subject: SubjectType?
    private var completion: _Subscribers.Completion<Failure>?
    private let lock: Locking = RecursiveLock()
    /// Creates a multicast publisher that applies a closure to create a subject that delivers elements to subscribers.
    /// - Parameter upstream: The publisher from which this publisher receives elements.
    /// - Parameter createSubject: A closure to create a new Subject each time a subscriber attaches to the multicast publisher.
    public init(upstream: Upstream, createSubject: @escaping () -> SubjectType) {
      self.upstream = upstream
      self.createSubject = createSubject
    }
    public func receive<S: _Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
      lock.withLock {
        if self.connection == nil {
          let subject = createSubject()
          self.subject = subject
          self.connection = upstream.subscribe(subject)
        }
      }
      subject?.subscribe(subscriber)
    }
    public func connect() -> _Cancellable {
      return lock.withLock {
        guard let connection = self.connection else {
          return _AnyCancellable {}
        }
        return _AnyCancellable {
          self.lock.withLock {
            self.connection = nil
            self.subject = nil
            connection.cancel()
          }
        }
      }
    }
  }
}
