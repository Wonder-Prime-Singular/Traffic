import XCTest
@testable import Traffic
import Combine
@available(OSX 10.15, *)
final class FilterTests: XCTestCase, TestCaseProtocol {
typealias Element = Int


  func testFilter1() -> Void {
    self.testSequence(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      return $0.filter(judge_true(a:))
    }, transform2: {
      return $0.filter(judge_true(a:))
    })
  }
  func testFilter2() -> Void {
    self.testSequence(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      return $0.filter(judge_false(a:))
    }, transform2: {
      return $0.filter(judge_false(a:))
    })
  }
  func testFilter3() -> Void {
    self.testSequence(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      return $0.filter(judge_depend(a:))
    }, transform2: {
      return $0.filter(judge_depend(a:))
    })
  }
  func testTryFilter1() -> Void {
    self.testSequence(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      return $0.tryFilter(judge_throws_conditionally(a:))
    }, transform2: {
      return $0.tryFilter(judge_throws_conditionally(a:))
    })
  }
  func testTryFilter2() -> Void {
    self.testSequence(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      return $0.tryFilter(judge_throws_unconditionally(a:))
    }, transform2: {
      return $0.tryFilter(judge_throws_unconditionally(a:))
    })
  }
}
