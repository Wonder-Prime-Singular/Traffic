/// Adds a `Publisher` to a property.
///
/// Properties annotated with `@Published` contain both the stored value and a publisher which sends any new values after the property value has been sent. New subscribers will receive the current value of the property first.
/// Note that the `@Published` property is class-constrained. Use it with properties of classes, not with non-class types like structures.
@propertyWrapper
public struct _Published<Value> {
  // see also: https://github.com/apple/swift/blob/master/test/decl/var/property_wrappers.swift
  private var value: Value
  @available(*, unavailable, message: "must be in a class")
  public var wrappedValue: Value {
    get { fatalError("called wrappedValue getter") }
    set { fatalError("called wrappedValue setter") }
  }
  public static subscript<EnclosingSelf: AnyObject>(_enclosingInstance observed: EnclosingSelf, wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Value>, storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, _Published<Value>>) -> Value {
    get {
      return observed[keyPath: storageKeyPath].value
    }
    set {
      observed[keyPath: storageKeyPath].projectedValue.subject.send(newValue)
      getPublisher(for: observed)?.send()
      observed[keyPath: storageKeyPath].value = newValue
    }
  }
  /// Initialize the storage of the Published property as well as the corresponding `Publisher`.
  public init(wrappedValue: Value) {
    self.value = wrappedValue
  }
  public init(initialValue: Value) {
    self.value = initialValue
  }
  /// A publisher for properties marked with the `@Published` attribute.
  public struct Publisher: _Publisher {
    public typealias Output = Value
    public typealias Failure = Never
    fileprivate let subject: _CurrentValueSubject<Output, Failure>
    public init(_ value: Value) {
      subject = .init(value)
    }
    public func receive<S: _Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
      subject.subscribe(subscriber)
    }
  }
  /// The property that can be accessed with the `$` syntax and allows access to the `Publisher`
  public private(set) lazy var projectedValue: _Published<Value>.Publisher = {
    return .init(value)
  }()
}
extension _Published: _ObservableObjectPublisherNameSpace {}
