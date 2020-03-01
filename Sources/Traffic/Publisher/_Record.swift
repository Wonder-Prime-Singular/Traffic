/// A publisher that allows for recording a series of inputs and a completion for later playback to each subscriber.
public struct _Record<Output, Failure: Swift.Error>: _Publisher {
  /// A recorded set of `Output` and a `Subscribers.Completion`.
  public struct Recording {
    public typealias Input = Output
    /// The output which will be sent to a `Subscriber`.
    public var output: [Output]
    /// The completion which will be sent to a `Subscriber`.
    public var completion: _Subscribers.Completion<Failure>
    /// Set up a recording in a state ready to receive output.
    public init() {
      output = []
      completion = .finished
    }
    /// Set up a complete recording with the specified output and completion.
    public init(output: [Output], completion: _Subscribers.Completion<Failure> = .finished) {
      self.output = output
      self.completion = completion
    }
    /// Add an output to the recording.
    ///
    /// A `fatalError` will be raised if output is added after adding completion.
    public mutating func receive(_ input: Input) {
      output.append(input)
    }
    /// Add a completion to the recording.
    ///
    /// A `fatalError` will be raised if more than one completion is added.
    public mutating func receive(completion: _Subscribers.Completion<Failure>) {
      self.completion = completion
    }
  }
  /// The recorded output and completion.
  public private(set) var recording: Recording
  /// Interactively record a series of outputs and a completion.
  public init(record: (inout Recording) -> Void) {
    recording = Recording()
    record(&recording)
  }
  /// Initialize with a recording.
  public init(recording: Recording) {
    self.recording = recording
  }
  /// Set up a complete recording with the specified output and completion.
  public init(output: [Output], completion: _Subscribers.Completion<Failure>) {
    recording = Recording(output: output, completion: completion)
  }
  public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
    let leading = _Subscriptions.Leading.Record(record: self, downstream: subscriber)
    subscriber.receive(subscription: leading)
  }
}
private extension _Subscriptions.Leading {
  class Record<Downstream: _Subscriber>: _Subscriptions.Leading.Simple<Downstream> {
    typealias Elements = [Downstream.Input]
    var output: Elements
    var iterator: Elements.Iterator
    var completion: _Subscribers.Completion<Downstream.Failure>
    func current() -> Elements.Element? {
      return iterator.next()
    }
    init(record: _Record<Downstream.Input, Downstream.Failure>, downstream: Downstream) {
      self.output = record.recording.output
      self.iterator = record.recording.output.makeIterator()
      self.completion = record.recording.completion
      super.init(downstream: downstream)
    }
    override func cancel() {
      downstream = nil
      output.removeAll()
      completion = .finished
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
            downstream.receive(completion: completion)
          }
        }
      }
    }
    override var description: String {
      return self.output.description
    }
  }
}
extension _Record.Recording: Decodable where Output: Decodable, Failure: Decodable {
  public init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    let output: [Output] = try container.decode([Output].self)
    let completion: _Subscribers.Completion<Failure> = try container.decode(_Subscribers.Completion<Failure>.self)
    self = .init(output: output, completion: completion)
  }
}
extension _Record.Recording: Encodable where Output: Encodable, Failure: Encodable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.unkeyedContainer()
    try container.encode(output)
    try container.encode(completion)
  }
}
extension _Record: Decodable where Output: Decodable, Failure: Decodable {
  public init(from decoder: Decoder) throws {
    self = .init(recording: try _Record.Recording(from: decoder))
  }
}
extension _Record: Encodable where Output: Encodable, Failure: Encodable {
  public func encode(to encoder: Encoder) throws {
    try self.recording.encode(to: encoder)
  }
}
