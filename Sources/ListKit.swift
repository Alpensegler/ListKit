public typealias UpdatableTableListAdapter = TableListAdapter & UpdatableDataSource
public typealias UpdatableCollectionListAdapter = CollectionListAdapter & UpdatableDataSource

public enum Log {
    public static var logger: ((String) -> Void)? = nil
    
    static func log(_ text: @autoclosure () -> String) {
        guard let logger = logger else { return }
        logger(text())
    }
}
