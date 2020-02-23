import Foundation
import Traffic
extension JSONDecoder: _TopLevelDecoder {
  public typealias Input = Data
}
extension JSONEncoder: _TopLevelEncoder {
  public typealias Output = Data
}
extension PropertyListDecoder: _TopLevelDecoder {
  public typealias Input = Data
}
extension PropertyListEncoder: _TopLevelEncoder {
  public typealias Output = Data
}
