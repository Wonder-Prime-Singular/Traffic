import XCTest
@testable import Traffic
@testable import TrafficExternal
import Combine
@available(OSX 10.15, *)
final class PublishedTests: XCTestCase, TestCaseProtocol {
typealias Element = Int

  func testTrafficObservable() -> Void {
    let john = TrafficContact(name: "John Appleseed", age: 24)
    _ = john.objectWillChange.sink { (_) in
      print("\(john.age) will change")
    }
    print(john.haveBirthday())
    // Prints "24 will change"
    // Prints "25"
  }
  func testTrafficNormal() -> Void {
    let john = TrafficContactNormal(name: "John Appleseed", age: 24)
    _ =  john.$age.sink { (_) in
      print("\(john.age) will change")
    }
    print(john.haveBirthday())
    // Prints "24 will change"
    // Prints "25"
  }
  func testCombine() -> Void {
    let john = CombineContact(name: "John Appleseed", age: 24)
    _ = john.$age.sink { (_) in
      print("\(john.age) will change")
    }
    print(john.haveBirthday())
    // Prints "24 will change"
    // Prints "25"
  }
}
class TrafficContact: Traffic.ObservableObject {
  @_Published var name: String
  @_Published var age: Int
  init(name: String, age: Int) {
    self.age = age
    self.name = name
  }
  func haveBirthday() -> Int {
    age += 1
    return age
  }
}
class TrafficContactSubclass: TrafficContact {
  @_Published var job: String
  init(name: String, age: Int, job: String) {
    self.job = job
    super.init(name: name, age: age)
  }
}
class TrafficContactNormal {
  @_Published var name: String
  @_Published var age: Int
  init(name: String, age: Int) {
    self.age = age
    self.name = name
  }
  func haveBirthday() -> Int {
    age += 1
    return age
  }
}
@available(OSX 10.15, *)
class CombineContact {
  @Published var name: String
  @Published var age: Int
  init(name: String, age: Int) {
    self.age = age
    self.name = name
  }
  func haveBirthday() -> Int {
    age += 1
    return age
  }
}
