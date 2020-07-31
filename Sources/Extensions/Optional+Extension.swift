//
//  Optional+Extension.swift
//  ListKit
//
//  Created by Frain on 2019/12/13.
//

extension Optional: DataSource where Wrapped: DataSource {
    public typealias Item = Wrapped.Item
    public typealias Source = Self
    public typealias SourceBase = Self
    
    public var source: Source { self }
    
    public var listUpdate: ListUpdate<SourceBase>.Whole {
        (source?.listUpdate).map { .init(way: $0.way) } ?? .reload
    }
    
    public var listOptions: ListOptions<SourceBase> {
        (source?.listOptions).map { .init($0) } ?? .none
    }
    
    public var listCoordinator: ListCoordinator<SourceBase> {
        switch self {
        case .some(let dataSource): return WrapperCoordinator(self, wrapped: dataSource) { $0 }
        case .none: return EmptyCoordinator(nil)
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
