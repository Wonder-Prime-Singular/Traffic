import XCTest
@testable import Traffic
import Combine
@available(OSX 10.15, *)
final class ComparisonTests: XCTestCase, TestCaseProtocol {
  typealias Element = Int
  @usableFromInline
  func testComparisonNoThrows(file: StaticString = #file, line: UInt = #line, elements: [Element], completion: _Subscribers.Completion<Error>, _ areInIncreasingOrder: @escaping (Int, Int) -> Bool) {
    self.testMany(file: file, line: line, elements: elements, completion: completion, transform1: {
      $0.max(by: areInIncreasingOrder)
    }, transform2: {
      $0.max(by: areInIncreasingOrder)
    })
    self.testMany(file: file, line: line, elements: elements, completion: completion, transform1: {
      $0.min(by: areInIncreasingOrder)
    }, transform2: {
      $0.min(by: areInIncreasingOrder)
    })
  }
  @usableFromInline
  func testComparisonThrows(file: StaticString = #file, line: UInt = #line, elements: [Element], completion: _Subscribers.Completion<Error>, _ areInIncreasingOrder: @escaping (Int, Int) throws -> Bool) {
    self.testMany(file: file, line: line, elements: elements, completion: completion, transform1: {
      $0.tryMax(by: areInIncreasingOrder)
    }, transform2: {
      $0.tryMax(by: areInIncreasingOrder)
    })
    self.testMany(file: file, line: line, elements: elements, completion: completion, transform1: {
      $0.tryMin(by: areInIncreasingOrder)
    }, transform2: {
      $0.tryMin(by: areInIncreasingOrder)
    })
  }
  @usableFromInline
  func testComparison(elements: [Element], completion: _Subscribers.Completion<Error>) {
    self.testMany(elements: elements, completion: completion, transform1: {
      $0.max()
    }, transform2: {
      $0.max()
    })
    self.testMany(elements: elements, completion: completion, transform1: {
      $0.min()
    }, transform2: {
      $0.min()
    })
    testComparisonNoThrows(elements: elements, completion: completion, compare_ascending(a:b:))
    testComparisonNoThrows(elements: elements, completion: completion, compare_disascending(a:b:))
    testComparisonThrows(elements: elements, completion: completion, compare_throws_unconditionally(a:b:))
    testComparisonThrows(elements: elements, completion: completion, compare_throws_ascending(a:b:))
    testComparisonThrows(elements: elements, completion: completion, compare_throws_disascending(a:b:))
  }
  func testComparison0() -> Void {
    testComparison(elements: [1], completion: .finished)
  }
  func testComparison1() -> Void {
    testComparison(elements: [0, 1], completion: .finished)
  }
  func testComparison2() -> Void {
    testComparison(elements: [1, 0], completion: .finished)
  }
  func testComparison3() -> Void {
    testComparison(elements: [0, 0], completion: .finished)
  }
  func testComparison10() -> Void {
    testComparison(elements: [1, 3, 2, 4, 5, 5, 8, 9, 0], completion: .finished)
  }
}
