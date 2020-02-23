import XCTest
@testable import Traffic
@testable import TrafficExternal
import Combine
@available(OSX 10.15, *)
final class NSObjectKVOPublisherTests: XCTestCase, TestCaseProtocol {
typealias Element = String

  func testRecursive() -> Void {
    let data1 = NSMutableData()
    let data2 = NSMutableData()
    var array1 = 5..<10
    var array2 = 5..<10
    let p1 = data1.trafficObject.publisher(for: \NSMutableData.length).map({ (l) in
      while !array1.isEmpty {
        let i = array1.removeFirst()
        data1.length = i // this is infinite recursive call
      }
      return l.description
    } as (Int) -> String)
    let p2 = data2.publisher(for: \NSMutableData.length).map({ (l) in
      while !array2.isEmpty {
        let i = array2.removeFirst()
        data2.length = i // this is infinite recursive call
      }
      return l.description
    } as (Int) -> String)
    sink(p1,
         p2)
    checkEqualAll()
  }
}
