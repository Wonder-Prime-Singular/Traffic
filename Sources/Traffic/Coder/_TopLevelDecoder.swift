public protocol _TopLevelDecoder {
  associatedtype Input
  func decode<T: Decodable>(_ type: T.Type, from: Self.Input) throws -> T
}
