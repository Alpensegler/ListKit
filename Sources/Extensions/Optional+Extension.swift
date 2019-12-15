//
//  Optional+Extension.swift
//  ListKit
//
//  Created by Frain on 2019/12/13.
//

extension Optional: DataSource where Wrapped: DataSource {
    public typealias Item = Wrapped.Item
    public typealias Source = Self
    
    public var source: Source { self }
    public var updater: Updater<Self> { .none }
    
    public func makeListCoordinator() -> ListCoordinator<Self> { .init() }
}

extension Optional: ScrollListAdapter where Wrapped: ScrollListAdapter { }
extension Optional: TableListAdapter where Wrapped: TableListAdapter {
    public var tableList: TableList<Self> { .init(self) }
}

extension Optional: CollectionListAdapter where Wrapped: CollectionListAdapter {
    public var collectionList: CollectionList<Self> { .init(self) }
}
