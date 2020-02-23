import XCTest
@testable import Traffic
import Combine
@available(OSX 10.15, *)
final class BreakpointTests: XCTestCase, TestCaseProtocol {
typealias Element = Int


  func testPublisher() -> Void {
    let array = [1, 2, 3, 4, 5]
    let s1 = _Publishers.Sequence<[Int], Swift.Error>(sequence: array)
    let s2 = Publishers.Sequence<[Int], Swift.Error>(sequence: array)
    sink(s1.breakpoint(),s2.breakpoint())
    checkEqualAll()
  }
}
