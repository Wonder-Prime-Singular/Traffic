import XCTest
@testable import Traffic
import Combine
@available(OSX 10.15, *)
final class FirstTests: XCTestCase, TestCaseProtocol {
typealias Element = Int


  func testFirst() -> Void {
    testSequence(elements: [], completion: .finished, transform1: {
      $0.first()
    }, transform2: {
      $0.first()
    })
    testSequence(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      $0.first()
    }, transform2: {
      $0.first()
    })
  }
  func testFirstWhere() -> Void {
    testSequence(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      $0.first(where: judge_true(a:))
    }, transform2: {
      $0.first(where: judge_true(a:))
    })
    testSequence(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      $0.first(where: judge_false(a:))
    }, transform2: {
      $0.first(where: judge_false(a:))
    })
    testSequence(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      $0.first(where: judge_depend(a:))
    }, transform2: {
      $0.first(where: judge_depend(a:))
    })
  }
  func testTryFirstWhere() -> Void {
    testSequence(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      $0.tryFirst(where: judge_throws_conditionally(a:))
    }, transform2: {
      $0.tryFirst(where: judge_throws_conditionally(a:))
    })
    testSequence(elements: [3, 4, 5], completion: .finished, transform1: {
      $0.tryFirst(where: judge_throws_conditionally(a:))
    }, transform2: {
      $0.tryFirst(where: judge_throws_conditionally(a:))
    })
    testSequence(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      $0.tryFirst(where: judge_throws_unconditionally(a:))
    }, transform2: {
      $0.tryFirst(where: judge_throws_unconditionally(a:))
    })
  }
}
