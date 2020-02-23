import XCTest
@testable import Traffic
import Combine
@available(OSX 10.15, *)
final class RecordTests: XCTestCase, TestCaseProtocol {
typealias Element = String

  func testRecording() -> Void {
    let array = stride(from: 1, to: 30, by: 2).map({ int in int.description })
    let r1 = _Record<String, Error>.init(output: array, completion: .finished)
    let r2 = Record<String, Error>.init(output: array, completion: .finished)
    sink(r1,
         r2)
    checkEqualAll()
  }
}
