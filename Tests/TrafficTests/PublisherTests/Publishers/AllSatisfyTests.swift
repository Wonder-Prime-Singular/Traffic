import XCTest
@testable import Traffic
import Combine
@available(OSX 10.15, *)
final class AllSatisfyTests: XCTestCase, TestCaseProtocol {
typealias Element = Bool

  func testAllSatisfy() -> Void {
    self.testMany(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      $0.allSatisfy({ a in a > 0 })
    }, transform2: {
      $0.allSatisfy({ a in a > 0 })
    })
    self.testMany(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      $0.allSatisfy({ a in a == 0 })
    }, transform2: {
      $0.allSatisfy({ a in a == 0 })
    })
    self.testMany(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      $0.allSatisfy({ a in a < 0 })
    }, transform2: {
      $0.allSatisfy({ a in a < 0 })
    })
    self.testMany(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      $0.allSatisfy({ a in a % 2 == 0 })
    }, transform2: {
      $0.allSatisfy({ a in a % 2 == 0 })
    })
    self.testMany(elements: [], completion: .finished, transform1: {
      $0.allSatisfy({ a in a > 0 })
    }, transform2: {
      $0.allSatisfy({ a in a > 0 })
    })
  }
}
