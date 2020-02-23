import XCTest
@testable import Traffic
import Combine
@available(OSX 10.15, *)
final class MapTests: XCTestCase, TestCaseProtocol {
  typealias Element = Int
  func testMap() -> Void {
    self.testSequence(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      $0.map({ a in 2 * a })
    }, transform2: {
      $0.map({ a in 2 * a })
    })
    self.testSequence(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      $0.tryMap({ a in if a / 2 == 0 { throw someError }; return 2 * a })
    }, transform2: {
      $0.tryMap({ a in if a / 2 == 0 { throw someError }; return 2 * a })
    })
    self.testSequence(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      $0.tryMap({ a in if a / 2 != 0 { throw someError }; return 2 * a })
    }, transform2: {
      $0.tryMap({ a in if a / 2 != 0 { throw someError }; return 2 * a })
    })
  }
}
