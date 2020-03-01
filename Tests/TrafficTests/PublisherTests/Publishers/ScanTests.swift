import XCTest
@testable import Traffic
import Combine
@available(OSX 10.15, *)
final class ScanTests: XCTestCase, TestCaseProtocol {
typealias Element = Int


  func testScan() -> Void {
    self.testMany(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      return $0.scan(0, add(a:b:))
    }, transform2: {
      return $0.scan(0, add(a:b:))
    })
  }
  func testTryScan() -> Void {
    self.testMany(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      return $0.tryScan(0, add(a:b:))
    }, transform2: {
      return $0.tryScan(0, add(a:b:))
    })
  }
  func testTryScan2() -> Void {
    self.testMany(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      return $0.tryScan(0, add_throws_conditionally(a:b:))
    }, transform2: {
      return $0.tryScan(0, add_throws_conditionally(a:b:))
    })
  }
  func testTryScan3() -> Void {
    self.testMany(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      return $0.tryScan(0, add_throws_unconditionally(a:b:))
    }, transform2: {
      return $0.tryScan(0, add_throws_unconditionally(a:b:))
    })
  }
}
