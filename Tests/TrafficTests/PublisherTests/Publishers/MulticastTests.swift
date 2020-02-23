import XCTest
@testable import Traffic
import Combine
@available(OSX 10.15, *)
final class MulticastTests: XCTestCase, TestCaseProtocol {
typealias Element = String
  func testMulticastPass() -> Void {
    let s1 = _PassthroughSubject<String, Swift.Error>()
    let s2 = PassthroughSubject<String, Swift.Error>()

    let m1 = s1.print().multicast({ return _PassthroughSubject<String, Swift.Error>() })
    let m2 = s2.print().multicast({ return PassthroughSubject<String, Swift.Error>() })

    _ = m1.connect()
    _ = m2.connect()

    sink(m1.map({ (s) in s }), m2.map({ (s) in s }))
//
    sink(m1.map({ (s) in s }), m2.map({ (s) in s }))

    var x = 0
    while x < 10  {
      s1.send(x.description)
      s2.send(x.description)
      x += 1
    }
    checkEqualAll()
  }
  func testMulticastPass2() -> Void {
    let s1 = _PassthroughSubject<String, Swift.Error>()
    let s2 = PassthroughSubject<String, Swift.Error>()

    let m1 = s1.print().multicast({ return _PassthroughSubject<String, Swift.Error>() })
    let m2 = s2.print().multicast({ return PassthroughSubject<String, Swift.Error>() })

    sink(m1.map({ (s) in s }), m2.map({ (s) in s }))

    let cancel_1 = m1.connect()
    let cancel_2 = m2.connect()

    var x = 0
    while x < 10  {
      s1.send(x.description)
      s2.send(x.description)
      x += 1
      if x == 6 {
        cancel_1.cancel()
        cancel_2.cancel()
      }
    }
    checkEqualAll()
    sink(m1.map({ (s) in s }), m2.map({ (s) in s }))

  }
  func testMulticastPass3() -> Void {
    let s1 = _PassthroughSubject<String, Swift.Error>()
    let s2 = PassthroughSubject<String, Swift.Error>()

    let m1 = s1.print().multicast({ return _PassthroughSubject<String, Swift.Error>() })
    let m2 = s2.print().multicast({ return PassthroughSubject<String, Swift.Error>() })

    sink(m1.map({ (s) in s }), m2.map({ (s) in s }))
//
    sink(m1.map({ (s) in s }), m2.map({ (s) in s }))

    _ = m1.connect()
    _ = m2.connect()

    var x = 0
    while x < 10  {
      s1.send(x.description)
      s2.send(x.description)
      x += 1
    }
    s1.send(completion: .finished)
    s2.send(completion: .finished)
    checkEqualAll()
  }
  func testMulticastPass4() -> Void {
    let s1 = _PassthroughSubject<String, Swift.Error>()
    let s2 = PassthroughSubject<String, Swift.Error>()

    s1.send("A")
    s2.send("A")

    s1.send(completion: .finished)
    s2.send(completion: .finished)

    let m1 = s1.print().multicast({ return _PassthroughSubject<String, Swift.Error>() })
    let m2 = s2.print().multicast({ return PassthroughSubject<String, Swift.Error>() })

    sink(m1.map({ (s) in s }), m2.map({ (s) in s }))
//
    sink(m1.map({ (s) in s }),
         m2.map({ (s) in s }))

    _ = m1.connect()
    _ = m2.connect()

    checkEqualAll()
  }
  func testMulticastPass5() -> Void {
    let s1 = _PassthroughSubject<String, Swift.Error>()
    let s2 = PassthroughSubject<String, Swift.Error>()

    let m1 = s1.print().multicast({ return _PassthroughSubject<String, Swift.Error>() })
    let m2 = s2.print().multicast({ return PassthroughSubject<String, Swift.Error>() })

    _ = m1.connect()
    _ = m2.connect()

    s1.send("A")
    s2.send("A")

    s1.send(completion: .finished)
    s2.send(completion: .finished)

    sink(m1.map({ (s) in s }),
         m2.map({ (s) in s }))
//
    sink(m1.map({ (s) in s }),
         m2.map({ (s) in s }))
    
    checkEqualAll()
  }
  func testMulticastCurrent() -> Void {
    let s1 = _PassthroughSubject<String, Swift.Error>()
    let s2 = PassthroughSubject<String, Swift.Error>()

    let m1 = s1.print("T").multicast({ return _CurrentValueSubject<String, Swift.Error>("A") })
    let m2 = s2.print("C").multicast({ return CurrentValueSubject<String, Swift.Error>("A") })

    sink(m1.map({ (s) in s }),
         m2.map({ (s) in s }))
//
    sink(m1.map({ (s) in s }),
         m2.map({ (s) in s }))

    _ = m1.connect()
    _ = m2.connect()

    var x = 0
    while x < 10  {
      s1.send(x.description)
      s2.send(x.description)
      x += 1
    }
    checkEqualAll()
  }
  func testMulticastCurrent2() -> Void {
    let s1 = _PassthroughSubject<String, Swift.Error>()
    let s2 = PassthroughSubject<String, Swift.Error>()
    let m1 = s1.print().multicast({ return _CurrentValueSubject<String, Swift.Error>("Q") })
    let m2 = s2.print().multicast({ return CurrentValueSubject<String, Swift.Error>("Q") })
    _ = m1.connect()
    _ = m2.connect()
    s1.send("A")
    s2.send("A")
    s1.send(completion: .finished)
    s2.send(completion: .finished)
    sink(m1.map({ (s) in s }), m2.map({ (s) in s }))
    sink(m1.map({ (s) in s }), m2.map({ (s) in s }))
    checkEqualAll()
  }
  func testMulticastCurrent3() -> Void {
    let s1 = _PassthroughSubject<String, Swift.Error>()
    let s2 = PassthroughSubject<String, Swift.Error>()
    let m1 = s1.print().multicast({ return _CurrentValueSubject<String, Swift.Error>("Q") })
    let m2 = s2.print().multicast({ return CurrentValueSubject<String, Swift.Error>("Q") })
    s1.send("A")
    s2.send("A")
    s1.send(completion: .finished)
    s2.send(completion: .finished)
    _ = m1.connect()
    _ = m2.connect()
    sink(m1.map({ (s) in s }), m2.map({ (s) in s }))
    sink(m1.map({ (s) in s }), m2.map({ (s) in s }))
    checkEqualAll()
  }
}
