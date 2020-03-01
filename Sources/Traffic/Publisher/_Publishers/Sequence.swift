extension _Publishers {
  /// A publisher that publishes a given sequence of elements.
  ///
  /// When the publisher exhausts the elements in the sequence, the next request causes the publisher to finish.
  public struct Sequence<Elements: Swift.Sequence, Failure: Swift.Error>: _Publisher {
    public typealias Output = Elements.Element
    /// The sequence of elements to publish.
    public let sequence: Elements
    /// Creates a publisher for a sequence of elements.
    ///
    /// - Parameter sequence: The sequence of elements to publish.
    public init(sequence: Elements) {
      self.sequence = sequence
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let leading = _Subscriptions.Leading.Sequence(sequence: self, downstream: subscriber)
      subscriber.receive(subscription: leading)
    }
  }
}
private extension _Subscriptions.Leading {
  class Sequence<Elements: Swift.Sequence, Downstream: _Subscriber>: _Subscriptions.Leading.Simple<Downstream> where Downstream.Input == Elements.Element {
    var iterator: Elements.Iterator
    func current() -> Elements.Element? {
      return iterator.next()
    }
    init(sequence: _Publishers.Sequence<Elements, Downstream.Failure>, downstream: Downstream) {
      self.iterator = sequence.sequence.makeIterator()
      super.init(downstream: downstream)
    }
    override func cancel() {
      downstream = nil
    }
    override func request(_ demand: _Subscribers.Demand) {
      lock.withLock {
        self.demand += demand
        while let downstream = self.downstream, self.demand > 0 {
          if let current = self.current() {
            self.demand -= 1
            self.demand += downstream.receive(current)
          } else {
            self.downstream = nil
            downstream.receive(completion: .finished)
          }
        }
      }
    }
    override var description: String {
      return "Sequence"
    }
  }
}
extension _Publishers.Sequence where Failure == Never {
  public func min(by areInIncreasingOrder: (Output, Output) -> Bool) -> _Optional<Output>.Publisher {
    return .init(sequence.min(by: areInIncreasingOrder))
  }
  public func max(by areInIncreasingOrder: (Output, Output) -> Bool) -> _Optional<Output>.Publisher {
    return .init(sequence.max(by: areInIncreasingOrder))
  }
  public func first(where predicate: (Output) -> Bool) -> _Optional<Output>.Publisher {
    return .init(sequence.first(where: predicate))
  }
}
extension _Publishers.Sequence {
  public func allSatisfy(_ predicate: (Output) -> Bool) -> _Result<Bool, Failure>.Publisher {
    return .init(sequence.allSatisfy(predicate))
  }
  public func tryAllSatisfy(_ predicate: (Output) throws -> Bool) -> _Result<Bool, Swift.Error>.Publisher {
    return .init(.init(catching: { try self.sequence.allSatisfy(predicate) }))
  }
  public func collect() -> _Result<[Output], Failure>.Publisher {
    return .init(Array(sequence))
  }
  public func compactMap<T>(_ transform: (Output) -> T?) -> _Publishers.Sequence<[T], Failure> {
    return .init(sequence: sequence.compactMap(transform))
  }
  public func contains(where predicate: (Output) -> Bool) -> _Result<Bool, Failure>.Publisher {
    return .init(sequence.contains(where: predicate))
  }
  public func tryContains(where predicate: (Output) throws -> Bool) -> _Result<Bool, Swift.Error>.Publisher {
    return .init(.init(catching: { try self.sequence.contains(where: predicate) }))
  }
  public func drop(while predicate: (Elements.Element) -> Bool) -> _Publishers.Sequence<DropWhileSequence<Elements>, Failure> {
    return .init(sequence: sequence.drop(while: predicate))
  }
  public func dropFirst(_ count: Int = 1) -> _Publishers.Sequence<DropFirstSequence<Elements>, Failure> {
    return .init(sequence: sequence.dropFirst(count))
  }
  public func filter(_ isIncluded: (Output) -> Bool) -> _Publishers.Sequence<[Output], Failure> {
    return .init(sequence: sequence.filter(isIncluded))
  }
  public func ignoreOutput() -> _Empty<Output, Failure> {
    return .init()
  }
  public func map<T>(_ transform: (Elements.Element) -> T) -> _Publishers.Sequence<[T], Failure> {
    return .init(sequence: sequence.map(transform))
  }
  public func prefix(_ maxLength: Int) -> _Publishers.Sequence<PrefixSequence<Elements>, Failure> {
    return .init(sequence: sequence.prefix(maxLength))
  }
  public func prefix(while predicate: (Elements.Element) -> Bool) -> _Publishers.Sequence<[Elements.Element], Failure> {
    return .init(sequence: sequence.prefix(while: predicate))
  }
  public func reduce<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Output) -> T) -> _Result<T, Failure>.Publisher {
    return .init(sequence.reduce(initialResult, nextPartialResult))
  }
  public func tryReduce<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Output) throws -> T) -> _Result<T, Swift.Error>.Publisher {
    return .init(.init(catching: { try self.sequence.reduce(initialResult, nextPartialResult) }))
  }
  public func replaceNil<T>(with output: T) -> _Publishers.Sequence<[Output], Failure> where Elements.Element == T? {
    return .init(sequence: sequence.map { (element) in element ?? output })
  }
  public func scan<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Output) -> T) -> _Publishers.Sequence<[T], Failure> {
    return .init(sequence: sequence.enumerated().map { (enumerated) in sequence.prefix(enumerated.offset).reduce(initialResult, nextPartialResult) })
  }
  public func setFailureType<E: Swift.Error>(to: E.Type) -> _Publishers.Sequence<Elements, E> {
    return .init(sequence: sequence)
  }
}
extension _Publishers.Sequence where Elements.Element: Equatable {
  public func removeDuplicates() -> _Publishers.Sequence<[Output], Failure> {
    var sequence = Array(self.sequence)
    sequence.sort(by: !=)
    for index in stride(from: sequence.count - 1, to: 0, by: -1) {
      if sequence[index] == sequence[index - 1] {
        sequence.remove(at: index)
      }
    }
    return .init(sequence: sequence)
  }
  public func contains(_ output: Elements.Element) -> _Result<Bool, Failure>.Publisher {
    return .init(sequence.contains(output))
  }
}
extension _Publishers.Sequence where Failure == Never, Elements.Element: Comparable {
  public func min() -> _Optional<Output>.Publisher {
    return .init(sequence.min())
  }
  public func max() -> _Optional<Output>.Publisher {
    return .init(sequence.max())
  }
}
extension _Publishers.Sequence where Elements: Collection, Failure == Never {
  public func first() -> _Optional<Output>.Publisher {
    return .init(sequence.first)
  }
  public func output(at index: Elements.Index) -> _Optional<Output>.Publisher {
    return .init(sequence[index])
  }
}
extension _Publishers.Sequence where Elements: Collection {
  public func count() -> _Result<Int, Failure>.Publisher {
    return .init(sequence.count)
  }
  public func output(in range: Range<Elements.Index>) -> _Publishers.Sequence<[Output], Failure> {
    return .init(sequence: Array(sequence[range]))
  }
}
extension _Publishers.Sequence where Elements: BidirectionalCollection, Failure == Never {
  public func last() -> _Optional<Output>.Publisher {
    return .init(sequence.last)
  }
  public func last(where predicate: (Output) -> Bool) -> _Optional<Output>.Publisher {
    return .init(sequence.last(where: predicate))
  }
}
extension _Publishers.Sequence where Elements: RandomAccessCollection, Failure == Never {
  public func output(at index: Elements.Index) -> _Optional<Output>.Publisher {
    return .init(sequence[index])
  }
}
extension _Publishers.Sequence where Elements: RandomAccessCollection {
  public func output(in range: Range<Elements.Index>) -> _Publishers.Sequence<[Output], Failure> {
    return .init(sequence: Array(sequence[range]))
  }
}
extension _Publishers.Sequence where Elements: RandomAccessCollection, Failure == Never {
  public func count() -> _Just<Int> {
    return .init(sequence.count)
  }
}
extension _Publishers.Sequence where Elements: RandomAccessCollection {
  public func count() -> _Result<Int, Failure>.Publisher {
    return .init(sequence.count)
  }
}
extension _Publishers.Sequence where Elements: RangeReplaceableCollection {
  public func prepend(_ elements: Output...) -> _Publishers.Sequence<Elements, Failure> {
    return .init(sequence: elements + sequence)
  }
  public func prepend<S: Swift.Sequence>(_ elements: S) -> _Publishers.Sequence<Elements, Failure> where Elements.Element == S.Element {
    return .init(sequence: elements + sequence)
  }
  public func prepend(_ publisher: _Publishers.Sequence<Elements, Failure>) -> _Publishers.Sequence<Elements, Failure> {
    return .init(sequence: publisher.sequence + sequence)
  }
  public func append(_ elements: Output...) -> _Publishers.Sequence<Elements, Failure> {
    return .init(sequence: sequence + elements)
  }
  public func append<S: Swift.Sequence>(_ elements: S) -> _Publishers.Sequence<Elements, Failure> where Elements.Element == S.Element {
    return .init(sequence: sequence + elements)
  }
  public func append(_ publisher: _Publishers.Sequence<Elements, Failure>) -> _Publishers.Sequence<Elements, Failure> {
    return .init(sequence: sequence + publisher.sequence)
  }
}
extension _Publishers.Sequence: Equatable where Elements: Equatable {}
