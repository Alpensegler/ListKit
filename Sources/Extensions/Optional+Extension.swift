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

    public var listDiffer: ListDiffer<SourceBase> {
        (source?.listDiffer).map { .init($0) } ?? .none
    }

    public var listUpdate: ListUpdate<SourceBase>.Whole {
        (source?.listUpdate).map { .init(way: $0.way) } ?? .reload
    }

    public var listOptions: ListOptions { source?.listOptions ?? .none }

    public var listCoordinator: ListCoordinator<SourceBase> {
        WrapperCoordinator(self, toItem: { $0 }, toOther: { $0 })
    }
}

extension Optional: ScrollListAdapter where Wrapped: ScrollListAdapter { }
extension Optional: TableListAdapter where Wrapped: TableListAdapter {
    public var tableList: TableList<Self> { .init(self) }
}

extension Optional: CollectionListAdapter where Wrapped: CollectionListAdapter {
    public var collectionList: CollectionList<Self> { .init(self) }
}

extension Optional {
    mutating func or(_ wrapped: @autoclosure () -> Wrapped) -> Wrapped {
        return self ?? {
            let wrapped = wrapped()
            self = wrapped
            return wrapped
        }()
    }
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

func notImplemented(function: StaticString = #function) -> Never {
    fatalError("\(function) not implemented")
}
