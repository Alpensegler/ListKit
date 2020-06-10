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
    
    public var listUpdate: ListUpdate<Item> { source?.listUpdate ?? .reload }
    public var listOptions: ListOptions<Self> {
        (source?.listOptions).map { .init($0) } ?? .none
    }
    
    public var listCoordinator: ListCoordinator<Self> {
        switch self {
        case .some(let dataSource):
            return WrapperCoordinator<Self, Wrapped>(self, wrapped: dataSource) { $0 }
        case .none:
            return EmptyCoordinator(sourceBase: nil)
        }
    }
}

extension Optional: ScrollListAdapter where Wrapped: ScrollListAdapter { }
extension Optional: TableListAdapter where Wrapped: TableListAdapter {
    public var tableList: TableList<Self> { .init(self) }
}

extension Optional: CollectionListAdapter where Wrapped: CollectionListAdapter {
    public var collectionList: CollectionList<Self> { .init(self) }
}

func + (lhs: (() -> Void)?, rhs: (() -> Void)?) -> (() -> Void)? {
    switch (lhs, rhs) {
    case let (lhs?, rhs?):
        return {
            lhs()
            rhs()
        }
    case let (lhs?, .none):
        return lhs
    case let (.none, rhs?):
        return rhs
    case (.none, .none):
        return nil
    }
}
