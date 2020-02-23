import XCTest
@testable import Traffic
import Combine
@available(OSX 10.15, *)
protocol SubjectTestCaseProtocol: TestCaseProtocol {
  associatedtype Element
  associatedtype S1: _Subject where S1.Output == Element
  associatedtype U2: Subject where U2.Output == Element
  func mySubject() -> S1
  func combineSubject() -> U2
}

@available(OSX 10.15, *)
extension SubjectTestCaseProtocol where Self: XCTestCase, Element == String {
  func _testSendValueEarly() {
    let s1 = mySubject()
    let s2 = combineSubject()
    s1.send("2")
    s2.send("2")
    sink(s1,s2)
    sink(s1,s2)
    checkEqualAll()
  }
  func _testSendValueCompletionEarly() {
    let s1 = mySubject()
    let s2 = combineSubject()
    s1.send("2")
    s1.send(completion: .finished)
    s2.send("2")
    s2.send(completion: .finished)
    sink(s1,s2)
    sink(s1,s2)
    checkEqualAll()
  }
  func _testSendValueAfterCompletion() {
    let s1 = mySubject()
    let s2 = combineSubject()
    s1.send("2")
    s1.send(completion: .finished)
    s2.send("2")
    s2.send(completion: .finished)
    sink(s1,
         s2)
    s1.send("3")
    s2.send("3")
    sink(s1,
         s2)
    checkEqualAll()
  }
  func _testSendValue1() {
    let s1 = mySubject()
    let s2 = combineSubject()
    sink(s1,
         s2)
    s1.send("2")
    s2.send("2")
    s1.send("3")
    s2.send("3")
    sink(s1,
         s2)
    checkEqualAll()
  }
  func _testSendValue2() {
    let s1 = mySubject()
    let s2 = combineSubject()
    s1.send("2")
    s2.send("2")
    sink(s1,
         s2)
    //
    sink(s1,
         s2)
    s1.send("3")
    s2.send("3")
    checkEqualAll()
  }
  func _testSendValue3() {
    let s1 = mySubject()
    let s2 = combineSubject()
    s1.send("2")
    s2.send("2")
    s1.send("3")
    s2.send("3")
    sink(s1,
         s2)
    //
    sink(s1,
         s2)
    checkEqualAll()
  }
  func _testSendValue4() {
    let s1 = mySubject()
    let s2 = combineSubject()
    s1.send("2")
    s2.send("2")
    sink(s1.print("T", to: nil),
         s2.print("C", to: nil))
    self.cancelAll()
    s1.send("3")
    s2.send("3")
    checkEqualAll()
  }
}
