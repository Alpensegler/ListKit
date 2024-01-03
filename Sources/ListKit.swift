public enum Log {
    public static var logger: ((String) -> Void)?

    static func log(_ text: @autoclosure () -> String?) {
        guard let logger = logger else { return }
        text().map(logger)
    }
}
