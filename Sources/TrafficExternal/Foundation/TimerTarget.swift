import Traffic
import Foundation
class TimerTarget: NSObject {
  private let action: () -> Void
  private let _lock: Locking = Lock()
  private var isCancelled: Bool = false
  internal init(action: @escaping () -> Void) {
    self.action = action
  }
  func cancel() {
    _lock.withLock {
      self.isCancelled = true
    }
  }
  @objc
  func fire(_ timer: Timer) {
    let isCancelled = _lock.withLock {
      self.isCancelled
    }
    guard !isCancelled else {
      timer.invalidate()
      return
    }
    action()
  }
}
