import XCTest
@testable import Traffic
import Combine
@available(OSX 10.15, *)
final class CombineLatestTests: XCTestCase, TestCaseProtocol {
typealias Element = String

  func testC2() -> Void {
    let s1a = _PassthroughSubject<String, Swift.Error>()
    let s1b = _PassthroughSubject<String, Swift.Error>()
    let s2a = PassthroughSubject<String, Swift.Error>()
    let s2b = PassthroughSubject<String, Swift.Error>()

    let z1 = s1a.combineLatest(s1b).map(+)
    let z2 = s2a.combineLatest(s2b).map(+)

    sink(z1,
         z2)

    var x = 0
    while x < 10  {
      let n = Int.random(in: 0..<2)
      switch n {
      case 0:
        s1a.send(x.description)
        s2a.send(x.description)
      case 1:
        s1b.send(x.description)
        s2b.send(x.description)
      default:
        break
      }
      x += 1
    }
    checkEqualAll()
  }
  func testC3() -> Void {
    let s1a = _PassthroughSubject<String, Swift.Error>()
    let s1b = _PassthroughSubject<String, Swift.Error>()
    let s1c = _PassthroughSubject<String, Swift.Error>()

    let s2a = PassthroughSubject<String, Swift.Error>()
    let s2b = PassthroughSubject<String, Swift.Error>()
    let s2c = PassthroughSubject<String, Swift.Error>()

    let z1 = s1a.combineLatest(s1b, s1c).map({ t in String(describing: t) })
    let z2 = s2a.combineLatest(s2b, s2c).map({ t in String(describing: t) })
    sink(z1,z2)

    var x = 0
    while x < 15  {
      let n = Int.random(in: 0..<3)
      switch n {
      case 0:
        s1a.send(x.description)
        s2a.send(x.description)
      case 1:
        s1b.send(x.description)
        s2b.send(x.description)
      case 2:
        s1c.send(x.description)
        s2c.send(x.description)
      default:
        break
      }
      x += 1
    }
    checkEqualAll()
  }
  func testC4() -> Void {
    let s1a = _PassthroughSubject<String, Swift.Error>()
    let s1b = _PassthroughSubject<String, Swift.Error>()
    let s1c = _PassthroughSubject<String, Swift.Error>()
    let s1d = _PassthroughSubject<String, Swift.Error>()

    let s2a = PassthroughSubject<String, Swift.Error>()
    let s2b = PassthroughSubject<String, Swift.Error>()
    let s2c = PassthroughSubject<String, Swift.Error>()
    let s2d = PassthroughSubject<String, Swift.Error>()

    let z1 = s1a.combineLatest(s1b, s1c, s1d).map({ t in String(describing: t) })
    let z2 = s2a.combineLatest(s2b, s2c, s2d).map({ t in String(describing: t) })
    sink(z1,z2)

    var x = 0
    while x < 20  {
      let n = Int.random(in: 0..<4)
      switch n {
      case 0:
        s1a.send(x.description)
        s2a.send(x.description)
      case 1:
        s1b.send(x.description)
        s2b.send(x.description)
      case 2:
        s1c.send(x.description)
        s2c.send(x.description)
      case 3:
        s1d.send(x.description)
        s2d.send(x.description)
      default:
        break
      }
      x += 1
    }
    checkEqualAll()
  }
}
