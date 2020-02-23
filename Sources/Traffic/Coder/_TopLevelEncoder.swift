public protocol _TopLevelEncoder {
  associatedtype Output
  func encode<T: Encodable>(_ value: T) throws -> Self.Output
}
