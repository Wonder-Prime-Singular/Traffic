public struct CombineIdentifier: Equatable, Hashable, CustomStringConvertible {
  private let id: String
  public init() {
    id = "any: \(UUID().uuidString)"
  }
  public init(_ object: AnyObject) {
    id = "object: \(ObjectIdentifier(object))"
  }
  public var description: String {
    return id
  }
}
