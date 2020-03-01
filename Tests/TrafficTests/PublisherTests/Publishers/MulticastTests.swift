import XCTest
@testable import Traffic
import Combine
@available(OSX 10.15, *)
final class MulticastTests: XCTestCase, TestCaseProtocol {
  typealias Element = Int
  func testMulticastPass() -> Void {
    let s1 = _PassthroughSubject<Int, Swift.Error>()
    let s2 = PassthroughSubject<Int, Swift.Error>()

    let m1 = s1.print().multicast({ return _PassthroughSubject<Int, Swift.Error>() })
    let m2 = s2.print().multicast({ return PassthroughSubject<Int, Swift.Error>() })

    let cancel_1 = m1.connect()
    let cancel_2 = m2.connect()
    self.hold(cancel_1)
    self.hold(cancel_2)
    sink(m1.map({ (s) in s }), m2.map({ (s) in s }))
    //
    sink(m1.map({ (s) in s }), m2.map({ (s) in s }))

    var x = 0
    while x < 10  {
      s1.send(x)
      s2.send(x)
      x += 1
    }
    checkEqualAll()
  }
  func testMulticastPass2() -> Void {
    let s1 = _PassthroughSubject<Int, Swift.Error>()
    let s2 = PassthroughSubject<Int, Swift.Error>()

    let m1 = s1.print().multicast({ return _PassthroughSubject<Int, Swift.Error>() })
    let m2 = s2.print().multicast({ return PassthroughSubject<Int, Swift.Error>() })

    sink(m1.map({ (s) in s }), m2.map({ (s) in s }))

    let cancel_1 = m1.connect()
    let cancel_2 = m2.connect()

    var x = 0
    while x < 10  {
      s1.send(x)
      s2.send(x)
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
    let s1 = _PassthroughSubject<Int, Swift.Error>()
    let s2 = PassthroughSubject<Int, Swift.Error>()

    let m1 = s1.print().multicast({ return _PassthroughSubject<Int, Swift.Error>() })
    let m2 = s2.print().multicast({ return PassthroughSubject<Int, Swift.Error>() })

    sink(m1.map({ (s) in s }), m2.map({ (s) in s }))
    //
    sink(m1.map({ (s) in s }), m2.map({ (s) in s }))

    let cancel_1 = m1.connect()
    let cancel_2 = m2.connect()
    self.hold(cancel_1)
    self.hold(cancel_2)

    var x = 0
    while x < 10  {
      s1.send(x)
      s2.send(x)
      x += 1
    }
    s1.send(completion: .finished)
    s2.send(completion: .finished)
    checkEqualAll()
  }
  func testMulticastPass4() -> Void {
    let s1 = _PassthroughSubject<Int, Swift.Error>()
    let s2 = PassthroughSubject<Int, Swift.Error>()

    s1.send(4)
    s2.send(4)

    s1.send(completion: .finished)
    s2.send(completion: .finished)

    let m1 = s1.print().multicast({ return _PassthroughSubject<Int, Swift.Error>() })
    let m2 = s2.print().multicast({ return PassthroughSubject<Int, Swift.Error>() })

    sink(m1.map({ (s) in s }), m2.map({ (s) in s }))
    //
    sink(m1.map({ (s) in s }),
         m2.map({ (s) in s }))

    let cancel_1 = m1.connect()
    let cancel_2 = m2.connect()
    self.hold(cancel_1)
    self.hold(cancel_2)

    checkEqualAll()
  }
  func testMulticastPass5() -> Void {
    let s1 = _PassthroughSubject<Int, Swift.Error>()
    let s2 = PassthroughSubject<Int, Swift.Error>()

    let m1 = s1.print().multicast({ return _PassthroughSubject<Int, Swift.Error>() })
    let m2 = s2.print().multicast({ return PassthroughSubject<Int, Swift.Error>() })

    let cancel_1 = m1.connect()
    let cancel_2 = m2.connect()
    self.hold(cancel_1)
    self.hold(cancel_2)

    s1.send(3)
    s2.send(3)

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
    let s1 = _PassthroughSubject<Int, Swift.Error>()
    let s2 = PassthroughSubject<Int, Swift.Error>()

    let m1 = s1.print("T").multicast({ return _CurrentValueSubject<Int, Swift.Error>(5) })
    let m2 = s2.print("C").multicast({ return CurrentValueSubject<Int, Swift.Error>(5) })

    sink(m1.map({ (s) in s }),
         m2.map({ (s) in s }))
    //
    sink(m1.map({ (s) in s }),
         m2.map({ (s) in s }))

    let cancel_1 = m1.connect()
    let cancel_2 = m2.connect()
    self.hold(cancel_1)
    self.hold(cancel_2)

    var x = 0
    while x < 10  {
      s1.send(x)
      s2.send(x)
      x += 1
    }
    checkEqualAll()
  }
  func testMulticastCurrent2() -> Void {
    let s1 = _PassthroughSubject<Int, Swift.Error>()
    let s2 = PassthroughSubject<Int, Swift.Error>()
    let m1 = s1.print().multicast({ return _CurrentValueSubject<Int, Swift.Error>(4) })
    let m2 = s2.print().multicast({ return CurrentValueSubject<Int, Swift.Error>(4) })
    let cancel_1 = m1.connect()
    let cancel_2 = m2.connect()
    self.hold(cancel_1)
    self.hold(cancel_2)
    s1.send(1)
    s2.send(1)
    s1.send(completion: .finished)
    s2.send(completion: .finished)
    sink(m1.map({ (s) in s }), m2.map({ (s) in s }))
    sink(m1.map({ (s) in s }), m2.map({ (s) in s }))
    checkEqualAll()
  }
  func testMulticastCurrent3() -> Void {
    let s1 = _PassthroughSubject<Int, Swift.Error>()
    let s2 = PassthroughSubject<Int, Swift.Error>()
    let m1 = s1.print().multicast({ return _CurrentValueSubject<Int, Swift.Error>(3) })
    let m2 = s2.print().multicast({ return CurrentValueSubject<Int, Swift.Error>(3) })
    s1.send(1)
    s2.send(1)
    s1.send(completion: .finished)
    s2.send(completion: .finished)
    let cancel_1 = m1.connect()
    let cancel_2 = m2.connect()
    self.hold(cancel_1)
    self.hold(cancel_2)
    sink(m1.map({ (s) in s }), m2.map({ (s) in s }))
    sink(m1.map({ (s) in s }), m2.map({ (s) in s }))
    checkEqualAll()
  }
}
