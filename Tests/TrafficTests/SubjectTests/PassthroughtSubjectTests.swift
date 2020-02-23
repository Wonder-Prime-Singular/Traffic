import XCTest
@testable import Traffic
import Combine
@available(OSX 10.15, *)
class PassthroughtSubjectTest: XCTestCase, SubjectTestCaseProtocol {
  typealias Element = String

  func mySubject() -> _PassthroughSubject<String, Swift.Error> {
    return .init()
  }
  func combineSubject() -> PassthroughSubject<String, Swift.Error> {
    return .init()
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
  func testSendValue4() {
    _testSendValue4()
  }
}
