public struct _Sequence<Wrapped: Swift.Sequence> {
  public let base: Wrapped
  public init(_ base: Wrapped) {
    self.base = base
  }
}
extension _Sequence {
  public var publisher: _Publishers.Sequence<Wrapped, Never> {
    return .init(sequence: self.base)
  }
}
