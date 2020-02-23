import XCTest
@testable import Traffic
import Combine
@available(OSX 10.15, *)
final class AssertNoFailureTests: XCTestCase, TestCaseProtocol {
typealias Element = Int


  func testFinished() -> Void {
    let array = [1, 2, 3, 4, 5]
    let s1 = _Publishers.Sequence<[Int], Swift.Error>(sequence: array)
    let s2 = Publishers.Sequence<[Int], Swift.Error>(sequence: array)
    assertNoBadInstruction {
      self.sink(s1.assertNoFailure(), s2.assertNoFailure())
    }
  }
  func testFailure() -> Void {
    let array = [1, 2, 3, 4, 5]
    let s1 = _Record<Int, Error>(output: array, completion: .failure(someError))
    let s2 = Record<Int, Error>(output: array, completion: .failure(someError))
    assertBadInstruction {
      self.sink(s1.assertNoFailure(), s2.assertNoFailure())
    }
  }
}
