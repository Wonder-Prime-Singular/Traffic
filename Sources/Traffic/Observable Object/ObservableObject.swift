/// A type of object with a publisher that emits before the object has changed.
///
/// By default an `ObservableObject` will synthesize an `objectWillChange`
/// publisher that emits before any of its `@Published` properties changes:
///
///     class Contact: ObservableObject {
///         @Published var name: String
///         @Published var age: Int
///
///         init(name: String, age: Int) {
///             self.name = name
///             self.age = age
///         }
///
///         func haveBirthday() -> Int {
///             age += 1
///             return age
///         }
///     }
///
///     let john = Contact(name: "John Appleseed", age: 24)
///     john.objectWillChange.sink { _ in print("\(john.age) will change") }
///     print(john.haveBirthday())
///     // Prints "24 will change"
///     // Prints "25"
///
public protocol ObservableObject: AnyObject {
  /// The type of publisher that emits before the object has changed.
  associatedtype ObjectWillChangePublisher: _Publisher = ObservableObjectPublisher where Self.ObjectWillChangePublisher.Failure == Never
  /// A publisher that emits before the object has changed.
  var objectWillChange: Self.ObjectWillChangePublisher { get }
}
import ObjectiveC.runtime
extension ObservableObjectPublisher {
  fileprivate enum AssociatedObjectKey {
    static var objectWillChange: String = "objectWillChange"
  }
}
extension ObservableObject where Self.ObjectWillChangePublisher == ObservableObjectPublisher {
  /// A publisher that emits before the object has changed.
  public var objectWillChange: ObservableObjectPublisher {
    let publisher = ObjectWillChangePublisher.getPublisher(for: self)!
    return publisher
  }
}
protocol _ObservableObjectPublisherNameSpace {
}
extension _ObservableObjectPublisherNameSpace {
  internal static func getPublisher(for object: AnyObject) -> ObservableObjectPublisher? {
    if let publisher = objc_getAssociatedObject(object, &ObservableObjectPublisher.AssociatedObjectKey.objectWillChange) as? ObservableObjectPublisher {
      return publisher
    }
    guard Self.self == ObservableObjectPublisher.self else {
      return nil
    }
    let publisher = ObservableObjectPublisher()
    objc_setAssociatedObject(object, &ObservableObjectPublisher.AssociatedObjectKey.objectWillChange, publisher, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return publisher
  }
}
extension ObservableObjectPublisher: _ObservableObjectPublisherNameSpace {}
