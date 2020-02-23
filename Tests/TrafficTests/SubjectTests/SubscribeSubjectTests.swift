import XCTest
@testable import Traffic
import Combine
@available(OSX 10.15, *)
final class SubscribeSubjectTests: XCTestCase, TestCaseProtocol {
typealias Element = String

  func testSubscribe() {
    let array = stride(from: 1, to: 30, by: 2).map({ int in int.description })
    let s1 = _CurrentValueSubject<String, Swift.Error>("1")
    let s2 = CurrentValueSubject<String, Swift.Error>("1")
    sink(s1,
         s2)
    let r1 = _Record<String, Error>.init(output: array, completion: .finished)
    let r2 = Record<String, Error>.init(output: array, completion: .finished)
    _ = r1.subscribe(s1)
    _ = r2.subscribe(s2)
    checkEqualAll()
  }
}
