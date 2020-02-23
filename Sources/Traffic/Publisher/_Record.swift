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
    let leading = _Subscriptions.Leading.Record(publisher: self, downstream: subscriber)
    subscriber.receive(subscription: leading)
  }
}
private extension _Subscriptions.Leading {
  class Record<Downstream: _Subscriber>: _Subscriptions.Leading.Base<_Record<Downstream.Input, Downstream.Failure>, Downstream> {
    override func cancel() {
      isCancelled = true
      downstream = nil
    }
    override func request(_ demand: _Subscribers.Demand) {
      guard !isCancelled else {
        return
      }
      var demand = demand
      for value in publisher.recording.output {
        demand -= downstream?.receive(value) ?? .none
        if demand <= .none {
          break
        }
      }
      downstream?.receive(completion: publisher.recording.completion)
    }
    override var description: String {
      return "Record"
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
