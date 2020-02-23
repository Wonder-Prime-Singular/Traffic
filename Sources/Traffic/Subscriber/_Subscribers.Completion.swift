extension _Subscribers {
  /// A signal that a publisher doesn’t produce additional elements, either due to normal completion or an error.
  ///
  /// - finished: The publisher finished normally.
  /// - failure: The publisher stopped publishing due to the indicated error.
  public enum Completion<Failure: Swift.Error> {
    case finished
    case failure(Failure)
    public func mapError<NewFailure: Swift.Error>(transform: (Failure) -> NewFailure) -> _Subscribers.Completion<NewFailure> {
      switch self {
      case let .failure(error):
        return .failure(transform(error))
      case .finished:
        return .finished
      }
    }
    public var isFinished: Bool {
      switch self {
      case .finished:
        return true
      default:
        return false
      }
    }
  }
}
extension _Subscribers.Completion: Encodable where Failure: Encodable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case let .failure(error):
      try container.encode(error)
    case .finished:
      try container.encodeNil()
    }
  }
}
extension _Subscribers.Completion: Decodable where Failure: Decodable {
  public init(from decoder: Decoder) throws {
    if try decoder.singleValueContainer().decodeNil() {
      self = .finished
    } else {
      self = .failure(try decoder.singleValueContainer().decode(Failure.self))
    }
  }
}
extension _Subscribers.Completion: Equatable where Failure: Equatable {}
extension _Subscribers.Completion: Hashable where Failure: Hashable {}
