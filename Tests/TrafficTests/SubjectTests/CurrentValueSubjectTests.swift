import XCTest
@testable import Traffic
import Combine
@available(OSX 10.15, *)
final class CurrentValueSubjectTests: XCTestCase, SubjectTestCaseProtocol {

  typealias Element = String

  func mySubject() -> _CurrentValueSubject<String, Swift.Error> {
    return .init("1")
  }
  func combineSubject() -> CurrentValueSubject<String, Swift.Error> {
    return .init("1")
  }
  func testSendValueEarly() {
    _testSendValueEarly()
  }
  func testSendValueCompletionEarly() {
    _testSendValueCompletionEarly()
  }
  func testSendValueAfterCompletion() {
    _testSendValueAfterCompletion()
  }
  func testSendValue1() {
    _testSendValue1()
  }
  func testSendValue2() {
    _testSendValue2()
  }
  func testSendValue3() {
    _testSendValue3()
  }
}
