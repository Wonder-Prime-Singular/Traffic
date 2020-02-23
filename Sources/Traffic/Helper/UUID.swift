import Darwin.uuid
struct UUID {
  internal let uuidString: String = {
    let uuid = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 16)
    defer {
      uuid.deallocate()
    }
    uuid.initialize(repeating: 0, count: 16)
    uuid_generate_random(uuid)
    let string = UnsafeMutablePointer<CChar>.allocate(capacity: 37)
    string.initialize(repeating: 0, count: 37)
    defer {
      string.deallocate()
    }
    uuid_unparse_upper(uuid, string)
    return String(cString: string)
  }()
  internal init() {}
}
