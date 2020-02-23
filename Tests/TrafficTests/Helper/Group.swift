import Foundation
class Group {
  private let lock = NSRecursiveLock()
  private var dict: [Int: Bool] = [:]
  private var condition: [Int] = [-1]
  var completionHandler: (() -> Void)?
  func setCompleted(_ index: Int) -> Void {
    lock.lock()
    dict[index] = true
    checkCompleted()
    lock.unlock()
  }
  func setCondition(_ indices: [Int]) -> Void {
    lock.lock()
    condition = indices
    checkCompleted()
    lock.unlock()
  }
  private func checkCompleted() -> Void {
    lock.lock()
    let array = condition.compactMap({ dict[$0] })
    if array.count == condition.count, Set(array) == Set([true]) {
      completionHandler?()
    }
    lock.unlock()
  }
}
