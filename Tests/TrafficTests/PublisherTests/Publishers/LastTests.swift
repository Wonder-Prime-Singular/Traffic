import XCTest
@testable import Traffic
import Combine
@available(OSX 10.15, *)
final class LastTests: XCTestCase, TestCaseProtocol {
typealias Element = Int


  func testLast() -> Void {
    testSequence(elements: [], completion: .finished, transform1: {
      $0.last()
    }, transform2: {
      $0.last()
    })
    testSequence(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      $0.last()
    }, transform2: {
      $0.last()
    })
  }
  func testLastWhere() -> Void {
    testSequence(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      $0.last(where: judge_true(a:))
    }, transform2: {
      $0.last(where: judge_true(a:))
    })
    testSequence(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      $0.last(where: judge_false(a:))
    }, transform2: {
      $0.last(where: judge_false(a:))
    })
    testSequence(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      $0.last(where: judge_depend(a:))
    }, transform2: {
      $0.last(where: judge_depend(a:))
    })
  }
  func testTryLastWhere() -> Void {
    testSequence(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      $0.tryLast(where: judge_throws_conditionally(a:))
    }, transform2: {
      $0.tryLast(where: judge_throws_conditionally(a:))
    })
    testSequence(elements: [3, 4, 5], completion: .finished, transform1: {
      $0.tryLast(where: judge_throws_conditionally(a:))
    }, transform2: {
      $0.tryLast(where: judge_throws_conditionally(a:))
    })
    testSequence(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      $0.tryLast(where: judge_throws_unconditionally(a:))
    }, transform2: {
      $0.tryLast(where: judge_throws_unconditionally(a:))
    })
  }
}
