import XCTest
@testable import Traffic
import Combine
@available(OSX 10.15, *)
final class AutoconnectTests: XCTestCase, TestCaseProtocol {
typealias Element = String

  func testAuto() -> Void {
    let s1 = _PassthroughSubject<String, Never>()
    let s2 = PassthroughSubject<String, Never>()
    let auto1 = s1.makeConnectable().autoconnect()
    let auto2 = s2.makeConnectable().autoconnect()
    let arrayX = 0..<10
    let arrayY = 20..<30

    sink(auto1.map({ (s) in s }),
         auto2.map({ (s) in s }))

    for x in arrayX  {
      s1.send(x.description)
      s2.send(x.description)
    }
    cancelAll()
    checkEqualAll()

    sink(auto1.map({ (s) in s }),auto2.map({ (s) in s }))

    for y in arrayY  {
      s1.send(y.description)
      s2.send(y.description)
    }
    checkEqualAll()
  }
}
