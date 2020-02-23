import Darwin.POSIX.pthread
public protocol Locking {
  func lock()
  func unlock()
  func `try`() -> Bool
}
public class Lock: Locking {
  private let _lock: UnsafeMutablePointer<pthread_mutex_t>
  private var _locked: Bool = false
  public init() {
    _lock = .allocate(capacity: 1)
    precondition(pthread_mutex_init(_lock, nil) == 0)
  }
  deinit {
    precondition(pthread_mutex_destroy(_lock) == 0)
    _lock.deallocate()
  }
  public func lock() {
    precondition(pthread_mutex_lock(_lock) == 0)
    _locked = true
  }
  public func unlock() {
    precondition(pthread_mutex_unlock(_lock) == 0)
    _locked = false
  }
  public func `try`() -> Bool {
    return !_locked
  }
}
public class RecursiveLock: Locking {
  private let _attr: UnsafeMutablePointer<pthread_mutexattr_t>
  private let _lock: UnsafeMutablePointer<pthread_mutex_t>
  private var _locked: Bool = false
  public init() {
    _lock = .allocate(capacity: 1)
    _attr = .allocate(capacity: 1)
    precondition(pthread_mutexattr_init(_attr) == 0)
    precondition(pthread_mutexattr_settype(_attr, PTHREAD_MUTEX_RECURSIVE) == 0)
    precondition(pthread_mutex_init(_lock, _attr) == 0)
  }
  deinit {
    precondition(pthread_mutex_destroy(_lock) == 0)
    precondition(pthread_mutexattr_destroy(_attr) == 0)
    _lock.deallocate()
    _attr.deallocate()
  }
  public func lock() {
    precondition(pthread_mutex_lock(_lock) == 0)
    _locked = true
  }
  public func unlock() {
    precondition(pthread_mutex_unlock(_lock) == 0)
    _locked = false
  }
  public func `try`() -> Bool {
    return !_locked
  }
}
extension Locking {
  @inlinable
  public func withLock<T>(_ block: () throws -> T) rethrows -> T {
    let lock = self
    lock.lock(); defer { lock.unlock() }
    return try block()
  }
  @inlinable
  public func withLock(_ block: () throws -> Void) rethrows {
    let lock = self
    lock.lock(); defer { lock.unlock() }
    try block()
  }
  @inlinable
  public func withTryLock<T>(_ block: () throws -> T) rethrows -> T {
    let lock = self
    guard lock.try() else {
      return try block()
    }
    lock.lock(); defer { lock.unlock() }
    return try block()
  }
  @inlinable
  public func withTryLock(_ block: () throws -> Void) rethrows {
    let lock = self
    guard lock.try() else {
      try block()
      return
    }
    lock.lock(); defer { lock.unlock() }
    try block()
  }
}
