/// A protocol indicating that an activity or action may be canceled.
///
/// Calling `cancel()` frees up any allocated resources. It also stops side effects such as timers, network access, or disk I/O.
public protocol _Cancellable {
  /// Cancel the activity.
  func cancel()
}
extension _Cancellable {
  /// Stores this Cancellable in the specified collection.
  /// Parameters:
  ///    - collection: The collection to store this Cancellable.
  public func store<C: RangeReplaceableCollection>(in collection: inout C) where C.Element == _AnyCancellable {
    collection.append(_AnyCancellable(self))
  }
  /// Stores this Cancellable in the specified set.
  /// Parameters:
  ///    - collection: The set to store this Cancellable.
  public func store(in set: inout Set<_AnyCancellable>) {
    set.insert(_AnyCancellable(self))
  }
}
