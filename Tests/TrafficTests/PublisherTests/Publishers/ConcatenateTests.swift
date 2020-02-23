import XCTest
@testable import Traffic
import Combine
@available(OSX 10.15, *)
final class ConcatenateTests: XCTestCase, TestCaseProtocol {
typealias Element = Int


  func testAppend() -> Void {
    let array = [5, 5, 8, 9, 0]
    let se1 = _Publishers.Sequence<[Int], Swift.Error>(sequence: array)
    let se2 = Publishers.Sequence<[Int], Swift.Error>(sequence: array)
    
    let su1 = _PassthroughSubject<Int, Swift.Error>()
    let su2 = PassthroughSubject<Int, Swift.Error>()

    let c1 = su1.append(se1)
    let c2 = su2.append(se2)
    sink(c1, c2)

    var x = 0
    while x < 10  {
      su1.send(x)
      su2.send(x)
      x += 1
    }

    checkEqualAll()

  }
  func testAppendComplete() -> Void {
    let array = [5, 5, 8, 9, 0]
    let se1 = _Publishers.Sequence<[Int], Swift.Error>(sequence: array)
    let se2 = Publishers.Sequence<[Int], Swift.Error>(sequence: array)
    
    let su1 = _PassthroughSubject<Int, Swift.Error>()
    let su2 = PassthroughSubject<Int, Swift.Error>()

    let c1 = su1.append(se1)
    let c2 = su2.append(se2)
    sink(c1.print("T"), c2.print("C"))
    var x = 0
    while x < 10  {
      su1.send(x)
      su2.send(x)
      x += 1
      if x == 5 {
        su1.send(completion: .finished)
        su2.send(completion: .finished)
      }
    }
    checkEqualAll()
  }
  func testPrepend() -> Void {
    let array = [5, 5, 8, 9, 0]
    let se1 = _Publishers.Sequence<[Int], Swift.Error>(sequence: array)
    let se2 = Publishers.Sequence<[Int], Swift.Error>(sequence: array)
    
    let su1 = _PassthroughSubject<Int, Swift.Error>()
    let su2 = PassthroughSubject<Int, Swift.Error>()
    
    let c1 = su1.prepend(se1)
    let c2 = su2.prepend(se2)
    sink(c1,
         c2)
    var x = 0
    while x < 10  {
      su1.send(x)
      su2.send(x)
      x += 1
    }
    checkEqualAll()

  }
}
