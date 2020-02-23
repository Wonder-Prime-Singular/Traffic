import XCTest
@testable import Traffic
import Combine

@available(OSX 10.15, *)
extension _Subscribers.Demand {
    static func == (lhs: _Subscribers.Demand, rhs: Subscribers.Demand) -> Bool {
        return lhs.max == rhs.max
    }
    static func == (lhs: Subscribers.Demand, rhs: _Subscribers.Demand) -> Bool {
        return lhs.max == rhs.max
    }
}
@available(OSX 10.15, *)
class DemandTests: XCTestCase, TestCaseProtocol {
typealias Element = Int
    func a(_ value: Int) -> _Subscribers.Demand {
        return _Subscribers.Demand.max(value)
    }
    func b(_ value: Int) -> Subscribers.Demand {
        return Subscribers.Demand.max(value)
    }
    func testMax() -> Void {
        XCTAssert(testOperationEqual({ return $0 }, { return $0 }))
    }
    @usableFromInline
    func testValueA() -> [_Subscribers.Demand] {
        return [_Subscribers.Demand.unlimited, _Subscribers.Demand.none, a(1), a(2), a(3), a(Int.max), a(Int.max - 1)]
    }
    @usableFromInline
    func testValueB() -> [Subscribers.Demand] {
        return [ Subscribers.Demand.unlimited,  Subscribers.Demand.none, b(1), b(2), b(3), b(Int.max), b(Int.max - 1)]
    }
    @usableFromInline
    func zipValues() -> Zip2Sequence<[_Subscribers.Demand], [Subscribers.Demand]> {
        return zip(testValueA(),
                   testValueB())
    }
    @usableFromInline
    func testOperation<A, B>(_ handler1: (_Subscribers.Demand) -> A, _ handler2: (Subscribers.Demand) -> B) -> [(a: A, b: B)] {
        return zipValues().map({ return (a: handler1($0.0), b: handler2($0.1)) })
    }
    @usableFromInline
    func testOperationEqual(_ handler1: (_Subscribers.Demand) -> _Subscribers.Demand, _ handler2: (Subscribers.Demand) -> Subscribers.Demand) -> Bool {
        return !testOperation(handler1, handler2).map(==).contains(false)
    }
    func testAdd() -> Void {
        zipValues().forEach { (arg) in
            let (a, b) = arg
            XCTAssert(testOperationEqual({ return $0 + a }, { return $0 + b }))
        }
    }
    func testMinus() -> Void {
        zipValues().forEach { (arg) in
            let (a, b) = arg
            XCTAssert(testOperationEqual({ (d) in
                if d.max != nil, a.max != nil {
                    if d.max! < a.max! {
                        return .none
                    }
                }
                let result = d - a
                print("A: \(d) - \(a) = \(result)")
                return result
            }, { (d) in
                if d.max != nil, b.max != nil {
                    if d.max! < b.max! {
                        return .none
                    }
                }
                let result = d - b
                print("B: \(d) - \(b) = \(result)")
                return result
            }))
        }
    }
    func testMultiply() -> Void {
        [2, Int.max / 2, Int.max].forEach { (m) in
            XCTAssert(testOperationEqual({ return $0 * m }, { return $0 * m }))
        }
    }
    func testCompare() -> Void {
        zipValues().forEach { (arg) in
            let (a, b) = arg
            XCTAssert(!testOperation({ return $0 < a }, { return $0 < b }).contains(where: { $0.a != $0.b }))
        }
        zipValues().forEach { (arg) in
            let (a, b) = arg
            XCTAssert(!testOperation({ return $0 <= a }, { return $0 <= b }).contains(where: { $0.a != $0.b }))
        }
    }
}
