func traffic_abstract_method(_ message: @autoclosure () -> String = String(), file: StaticString = #file, line: UInt = #line, function: StaticString = #function) -> Never {
  fatalError("\(function)" + message(), file: file, line: line)
}
