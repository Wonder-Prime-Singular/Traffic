extension _Publisher {
  public func subscribe<S: _Subject>(_ subject: S) -> _AnyCancellable where Self.Failure == S.Failure, Self.Output == S.Output {
    let downstream = SubjectSubscriber(subject)
    subscribe(downstream)
    return _AnyCancellable(downstream)
  }
}
