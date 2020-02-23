import XCTest
@testable import Traffic
import Combine
@available(OSX 10.15, *)
final class PrefixWhileTests: XCTestCase, TestCaseProtocol {
typealias Element = Int


  func testPrefixWhile1() -> Void {
    self.testSequence(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      return $0.prefix(while: judge_true(a:))
    }, transform2: {
      return $0.prefix(while: judge_true(a:))
    })
  }
  func testPrefixWhile2() -> Void {
    self.testSequence(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      return $0.prefix(while: judge_false(a:))
    }, transform2: {
      return $0.prefix(while: judge_false(a:))
    })
  }
  func testPrefixWhile3() -> Void {
    self.testSequence(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      return $0.prefix(while: judge_depend(a:))
    }, transform2: {
      return $0.prefix(while: judge_depend(a:))
    })
  }
  func testTryPrefixWhile1() -> Void {
    self.testSequence(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      return $0.tryPrefix(while: judge_throws_conditionally(a:))
    }, transform2: {
      return $0.tryPrefix(while: judge_throws_conditionally(a:))
    })
  }
  func testTryPrefixWhile2() -> Void {
    self.testSequence(elements: [1, 2, 3, 4, 5], completion: .finished, transform1: {
      return $0.tryPrefix(while: judge_throws_unconditionally(a:))
    }, transform2: {
      return $0.tryPrefix(while: judge_throws_unconditionally(a:))
    })
  }
}
