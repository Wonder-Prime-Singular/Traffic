/// A publisher that emits an output to each subscriber just once, and then finishes.
///
/// You can use a `Just` publisher to start a chain of publishers. A `Just` publisher is also useful when replacing a value with `Catch`.
///
/// In contrast with `Publishers.Once`, a `Just` publisher cannot fail with an error.
public struct _Just<Output>: _Publisher {
  public typealias Failure = Never
  /// The one element that the publisher emits.
  public let output: Output
  /// Initializes a publisher that emits the specified output just once.
  ///
  /// - Parameter output: The one element that the publisher emits.
  public init(_ output: Output) {
    self.output = output
  }
  public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
    let leading = _Subscriptions.Leading.Just(publisher: self, downstream: subscriber)
    subscriber.receive(subscription: leading)
    _ = subscriber.receive(self.output)
    subscriber.receive(completion: .finished)
  }
}
private extension _Subscriptions.Leading {
  class Just<Downstream: _Subscriber>: _Subscriptions.Leading.Base<_Just<Downstream.Input>, Downstream> where Downstream.Failure == Never {
    override func cancel() {
      downstream = nil
    }
    override func request(_ demand: _Subscribers.Demand) {
      
    }
    override var description: String {
      return "Just"
    }
  }
}
extension _Just {
  public func allSatisfy(_ predicate: (Output) -> Bool) -> _Just<Bool> {
    return .init(predicate(output))
  }
  public func tryAllSatisfy(_ predicate: (Output) throws -> Bool) -> _Result<Bool, Swift.Error>.Publisher {
    return .init(.init(catching: { try predicate(self.output) }))
  }
  public func collect() -> _Just<[Output]> {
    return .init([output])
  }
  public func compactMap<T>(_ transform: (Output) -> T?) -> _Optional<T>.Publisher {
    return .init(transform(output))
  }
  public func min(by: (Output, Output) -> Bool) -> _Just<Output> {
    return self
  }
  public func max(by: (Output, Output) -> Bool) -> _Just<Output> {
    return self
  }
  public func prepend(_ elements: Output...) -> _Publishers.Sequence<[Output], Failure> {
    return .init(sequence: elements + [output])
  }
  public func prepend<S>(_ elements: S) -> _Publishers.Sequence<[Output], Failure> where Output == S.Element, S: Swift.Sequence {
    return .init(sequence: elements + [output])
  }
  public func append(_ elements: Output...) -> _Publishers.Sequence<[Output], Failure> {
    return .init(sequence: [output] + elements)
  }
  public func append<S>(_ elements: S) -> _Publishers.Sequence<[Output], Failure> where Output == S.Element, S: Swift.Sequence {
    return .init(sequence: [output] + elements)
  }
  public func contains(where predicate: (Output) -> Bool) -> _Just<Bool> {
    return .init(predicate(output))
  }
  public func tryContains(where predicate: (Output) throws -> Bool) -> _Result<Bool, Swift.Error>.Publisher {
    return .init(.init(catching: { try predicate(self.output) }))
  }
  public func count() -> _Just<Int> {
    return .init(1)
  }
  public func dropFirst(_ count: Int = 1) -> _Optional<Output>.Publisher {
    return .init(count > 0 ? nil : output)
  }
  public func drop(while predicate: (Output) -> Bool) -> _Optional<Output>.Publisher {
    return .init(predicate(output) ? nil : output)
  }
  public func first() -> _Just<Output> {
    return self
  }
  public func first(where predicate: (Output) -> Bool) -> _Optional<Output>.Publisher {
    return .init(predicate(output) ? output : nil)
  }
  public func last() -> _Just<Output> {
    return self
  }
  public func last(where predicate: (Output) -> Bool) -> _Optional<Output>.Publisher {
    return .init(predicate(output) ? output : nil)
  }
  public func filter(_ isIncluded: (Output) -> Bool) -> _Optional<Output>.Publisher {
    return .init(isIncluded(output) ? output : nil)
  }
  public func ignoreOutput() -> _Empty<Output, Failure> {
    return .init()
  }
  public func map<T>(_ transform: (Output) -> T) -> _Just<T> {
    return .init(transform(output))
  }
  public func tryMap<T>(_ transform: (Output) throws -> T) -> _Result<T, Swift.Error>.Publisher {
    return .init(.init(catching: { try transform(self.output) }))
  }
  public func mapError<E: Swift.Error>(_: (Failure) -> E) -> _Result<Output, E>.Publisher {
    return .init(output)
  }
  public func output(at index: Int) -> _Optional<Output>.Publisher {
    return .init(index == 0 ? output : nil)
  }
  public func output<R: RangeExpression>(in range: R) -> _Optional<Output>.Publisher where R.Bound == Int {
    return .init(range.contains(0) ? output : nil)
  }
  public func prefix(_ maxLength: Int) -> _Optional<Output>.Publisher {
    return .init(maxLength >= 0 ? output : nil)
  }
  public func prefix(while predicate: (Output) -> Bool) -> _Optional<Output>.Publisher {
    return .init(predicate(output) ? output : nil)
  }
  public func reduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> _Result<T, Failure>.Publisher {
    return .init(nextPartialResult(initialResult, output))
  }
  public func tryReduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> _Result<T, Swift.Error>.Publisher {
    return .init(.init(catching: { try nextPartialResult(initialResult, self.output) }))
  }
  public func removeDuplicates(by: (Output, Output) -> Bool) -> _Just<Output> {
    return self
  }
  public func tryRemoveDuplicates(by: (Output, Output) throws -> Bool) -> _Result<Output, Swift.Error>.Publisher {
    return .init(output)
  }
  public func replaceError(with: Output) -> _Just<Output> {
    return self
  }
  public func replaceEmpty(with: Output) -> _Just<Output> {
    return self
  }
  public func retry(_: Int) -> _Just<Output> {
    return self
  }
  public func scan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> _Result<T, Failure>.Publisher {
    return .init(nextPartialResult(initialResult, output))
  }
  public func tryScan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> _Result<T, Swift.Error>.Publisher {
    return .init(.init(catching: { try nextPartialResult(initialResult, self.output) }))
  }
  public func setFailureType<E: Swift.Error>(to: E.Type) -> _Result<Output, E>.Publisher {
    return .init(output)
  }
}
extension _Just: Equatable where Output: Equatable {
}
extension _Just where Output : Comparable {
  public func min() -> _Just<Output> {
    return self
  }
  public func max() -> _Just<Output> {
    return self
  }
}
extension _Just where Output: Equatable {
  public func contains(_ output: Output) -> _Just<Bool> {
    return .init(self.output == output)
  }
  public func removeDuplicates() -> _Just<Output> {
    return self
  }
}
