import XCTest
@testable import Traffic
import Combine
@available(OSX 10.15, *)
final class SwitchToLatestTests: XCTestCase, TestCaseProtocol {
typealias Element = String

  func testFail() {
    let s1a = _PassthroughSubject<String, Swift.Error>()
    let s2a = PassthroughSubject<String, Swift.Error>()
    sink(s1a.map({ (s) in
      if s == "8" {
        return _Fail(outputType: String.self, failure: someError as Error).eraseToAnyPublisher()
      }
      return _Just<String>(s).setFailureType(to: Swift.Error.self).eraseToAnyPublisher()
      } as (String) -> _AnyPublisher<String, Error>).switchToLatest(), s2a.map({ (s) in
      if s == "8" {
        return Fail(outputType: String.self, failure: someError as Error).eraseToAnyPublisher()
      }
      return Just<String>(s).setFailureType(to: Swift.Error.self).eraseToAnyPublisher()
      } as (String) -> AnyPublisher<String, Error>).switchToLatest())
    var x = 0
    while x < 10  {
      s1a.send(x.description)
      s2a.send(x.description)
      x += 1
    }
    s1a.send(completion: .finished)
    s2a.send(completion: .finished)
    checkEqualAll()
  }
  func testSwitchComplete() -> Void {
    let s1a = _PassthroughSubject<String, Swift.Error>()
    let s2a = PassthroughSubject<String, Swift.Error>()

    sink(s1a.map({ (s) in _Just<String>(s).setFailureType(to: Swift.Error.self) }).switchToLatest(),
              s2a.map({ (s) in Just<String>(s).setFailureType(to: Swift.Error.self) }).switchToLatest())

    var x = 0
    while x < 10  {
      s1a.send(x.description)
      s2a.send(x.description)
      x += 1
    }
    s1a.send(completion: .finished)
    s2a.send(completion: .finished)
    checkEqualAll()
  }
  func testSwitch() -> Void {
    let s1a = _PassthroughSubject<String, Swift.Error>()
    let s2a = PassthroughSubject<String, Swift.Error>()

    sink(s1a.map({ (s) in _Just<String>(s.description).setFailureType(to: Swift.Error.self) }).switchToLatest(),
              s2a.map({ (s) in Just<String>(s.description).setFailureType(to: Swift.Error.self) }).switchToLatest())

    var x = 0
    while x < 10  {
      s1a.send(x.description)
      s2a.send(x.description)
      x += 1
    }
    
    checkEqualAll()
  }
  func testSwitch2() -> Void {
    let s1a = _PassthroughSubject<String, Swift.Error>()
    let s2a = PassthroughSubject<String, Swift.Error>()

    var sync: [String: Two] = [:]

    class Two {
      let name: String
      init(name: String) {
        self.name = name
      }
      var subject1: _PassthroughSubject<String, Swift.Error>? {
        didSet {
          fireIfNeeded()
        }
      }
      var subject2: PassthroughSubject<String, Swift.Error>? {
        didSet {
          fireIfNeeded()
        }
      }
      func fireIfNeeded() {
        guard subject1 != nil, subject2 != nil else {
          return
        }
        for i in 0..<5 {
          DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.milliseconds(50 * i)) {
            self.subject1?.send(self.name)
            self.subject2?.send(self.name)
          }
        }
      }
    }

    sink(s1a.map({ (s) in
      let su = _PassthroughSubject<String, Swift.Error>()
      sync[s]?.subject1 = su
      return su
    } as (String) -> _PassthroughSubject<String, Swift.Error>).switchToLatest().print("T"),
         s2a.map({ (s) in
      let su = PassthroughSubject<String, Swift.Error>()
      sync[s]?.subject2 = su
      return su
    } as (String) -> PassthroughSubject<String, Swift.Error>).switchToLatest().print("C"))

    var x = 0
    while x < 10  {
      sync[x.description] = Two(name: x.description)
      s1a.send(x.description)
      s2a.send(x.description)
      x += 1
    }
    let e = XCTestExpectation(description: "")
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      e.fulfill()
    }
    wait(for: [e], timeout: 2)
    checkEqualAll()
  }
}
