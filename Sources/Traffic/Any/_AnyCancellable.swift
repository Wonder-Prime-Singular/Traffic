/// A type-erasing cancellable object that executes a provided closure when canceled.
///
/// Subscriber implementations can use this type to provide a “cancellation token” that makes it possible for a caller to cancel a publisher, but not to use the `Subscription` object to request items.
/// An AnyCancellable instance automatically calls `cancel()` when deinitialized.
public final class _AnyCancellable: _Cancellable, Equatable, Hashable {
  private var isCancelled: Bool = false
  private let closure: () -> Void
  private var canceller: _Cancellable?
  /// Initializes the cancellable object with the given cancel-time closure.
  ///
  /// - Parameter cancel: A closure that the `cancel()` method executes.
  public init(_ cancel: @escaping () -> Void) {
    closure = cancel
  }
  public init<C: _Cancellable>(_ canceller: C) {
    closure = {}
    self.canceller = canceller
  }
  deinit {
    cancel()
  }
  public func cancel() {
    guard !isCancelled else { return }
    isCancelled = true
    closure()
    canceller?.cancel()
    canceller = nil
  }
  public static func == (lhs: _AnyCancellable, rhs: _AnyCancellable) -> Bool {
    return lhs === rhs
  }
  public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }
}
extension _AnyCancellable {
  /// Stores this AnyCancellable in the specified collection.
  /// Parameters:
  ///    - collection: The collection to store this AnyCancellable.
  public final func store<C: RangeReplaceableCollection>(in collection: inout C) where C.Element == _AnyCancellable {
    collection.append(self)
  }
  /// Stores this AnyCancellable in the specified set.
  /// Parameters:
  ///    - collection: The set to store this AnyCancellable.
  public final func store(in set: inout Set<_AnyCancellable>) {
    set.insert(self)
  }
}
