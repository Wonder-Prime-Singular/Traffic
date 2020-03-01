import XCTest
@testable import Traffic
import Combine
@available(OSX 10.15, *)
final class CompactMapTests: XCTestCase, TestCaseProtocol {
  typealias Element = Int
  func testCompactMap() -> Void {
    self.testMany(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      $0.compactMap({ a in 2 * a })
    }, transform2: {
      $0.compactMap({ a in 2 * a })
    })
    self.testMany(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      $0.compactMap({ a in a / 2 == 0 ? nil : 2 * a })
    }, transform2: {
      $0.compactMap({ a in a / 2 == 0 ? nil : 2 * a })
    })
    self.testMany(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      $0.tryCompactMap({ a in if a / 2 == 0 { throw someError }; return 2 * a })
    }, transform2: {
      $0.tryCompactMap({ a in if a / 2 == 0 { throw someError }; return 2 * a })
    })
    self.testMany(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      $0.tryCompactMap({ a in if a / 2 != 0 { throw someError }; return 2 * a })
    }, transform2: {
      $0.tryCompactMap({ a in if a / 2 != 0 { throw someError }; return 2 * a })
    })
  }
}
