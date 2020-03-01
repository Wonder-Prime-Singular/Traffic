import XCTest
@testable import Traffic
import Combine
@available(OSX 10.15, *)
final class ReduceTests: XCTestCase, TestCaseProtocol {
typealias Element = Int


  func testReduce() -> Void {
    self.testMany(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      return $0.reduce(0, add(a:b:))
    }, transform2: {
      return $0.reduce(0, add(a:b:))
    })
  }
  func testTryReduce() -> Void {
    self.testMany(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      return $0.tryReduce(0, add(a:b:))
    }, transform2: {
      return $0.tryReduce(0, add(a:b:))
    })
  }
  func testTryReduce2() -> Void {
    self.testMany(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      return $0.tryReduce(0, add_throws_conditionally(a:b:))
    }, transform2: {
      return $0.tryReduce(0, add_throws_conditionally(a:b:))
    })
  }
  func testTryReduce3() -> Void {
    self.testMany(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      return $0.tryReduce(0, add_throws_unconditionally(a:b:))
    }, transform2: {
      return $0.tryReduce(0, add_throws_unconditionally(a:b:))
    })
  }
}
