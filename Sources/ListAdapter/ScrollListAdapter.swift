//
//  ScrollListAdapter.swift
//  ListKit
//
//  Created by Frain on 2019/12/5.
//

public protocol ScrollListAdapter: DataSource {
    var scrollList: ScrollList<SourceBase> { get }
}

public extension ScrollListAdapter {
    var scrollList: ScrollList<SourceBase> {
        let scrollList = ScrollList(source: sourceBase)
        scrollList.coordinatorStorage.coordinator = listCoordinator
        return scrollList
    }
}

@propertyWrapper
@dynamicMemberLookup
public struct ScrollList<Source: DataSource>: ScrollListAdapter, UpdatableDataSource
where Source.SourceBase == Source {
    public typealias Item = Source.Item
    public typealias SourceBase = Source
    
    public let source: Source
    public let coordinatorStorage = CoordinatorStorage<Source>()
    
    public var updater: Updater<Source> { source.updater }
    public var sourceBase: Source { source }
    public func makeListCoordinator() -> ListCoordinator<Source> {
        addToStorage(source.makeListCoordinator())
    }
    
    public var wrappedValue: Source { source }
    public var projectedValue: Source.Source { source.source }
    
    public subscript<Value>(dynamicMember path: KeyPath<Source, Value>) -> Value {
        source[keyPath: path]
    }
}

extension ScrollListAdapter {
    func set<Object: AnyObject, Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<BaseCoordinator, Delegate<Object, Input, Output>>,
        _ closure: @escaping ((Object, Input)) -> Output
    ) -> ScrollList<SourceBase> {
        let scrollList = self.scrollList
        scrollList.listCoordinator.set(keyPath, closure)
        return scrollList
    }

    func set<Object: AnyObject, Input>(
        _ keyPath: ReferenceWritableKeyPath<BaseCoordinator, Delegate<Object, Input, Void>>,
        _ closure: @escaping ((Object, Input)) -> Void
    ) -> ScrollList<SourceBase> {
        let scrollList = self.scrollList
        scrollList.listCoordinator.set(keyPath, closure)
        return scrollList
    }
}
