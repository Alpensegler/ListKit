//
//  ListAdapter.swift
//  ListKit
//
//  Created by Frain on 2019/12/16.
//

import Foundation

protocol ListAdapter: UpdatableDataSource where Source == SourceBase {
    associatedtype View: AnyObject
    associatedtype ViewDelegates: AnyObject
    associatedtype ErasedType
    
    var erasedGetter: (Self) -> ErasedType { get }
    static var defaultErasedGetter: (Self) -> ErasedType { get }
    static var rootKeyPath: ReferenceWritableKeyPath<CoordinatorContext, ViewDelegates> { get }
    
    init(
        listContextSetups: [(ListCoordinatorContext<SourceBase>) -> Void],
        source: Source,
        erasedGetter: @escaping (Self) -> ErasedType
    )
}

final class ListAdapterStorage<Source: DataSource> where Source.SourceBase == Source {
    var source: Source
    var makeListCoordinator: () -> ListCoordinator<Source> = { fatalError() }
    
    lazy var listCoordinator = makeListCoordinator()
    lazy var coordinatorStorage = listCoordinator.storage.or(.init())
    
    init(source: Source) {
        self.source = source
    }
}

extension ListAdapter {
    init<OtherSource: DataSource>(
        _ dataSource: OtherSource,
        erasedGetter: @escaping (Self) -> ErasedType = Self.defaultErasedGetter
    ) where OtherSource.SourceBase == Source {
        self.init(listContextSetups: [], source: dataSource.sourceBase, erasedGetter: erasedGetter)
    }

    init<OtherSource: ListAdapter>(
        _ dataSource: OtherSource
    ) where OtherSource.SourceBase == Source {
        self.init(
            listContextSetups: dataSource.listContextSetups,
            source: dataSource.sourceBase,
            erasedGetter: Self.defaultErasedGetter
        )
    }

    init<OtherSource: ListAdapter>(
        erase dataSource: OtherSource
    ) where Self == OtherSource.ErasedType {
        self = dataSource.erased
    }
    
    var erased: ErasedType { erasedGetter(self) }

    func set<Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<ViewDelegates, Delegate<View, Input, Output>>,
        _ closure: @escaping ((ListContext<View, Source>, Input)) -> Output
    ) -> Self {
        var setups = listContextSetups
        setups.append {
            let keyPath = Self.rootKeyPath.appending(path: keyPath)
            $0.set(keyPath) { (context, object, input, root) in
                closure((.init(context: context, listView: object, root: root), input))
            }
        }
        return .init(listContextSetups: setups, source: source, erasedGetter: erasedGetter)
    }

    func set<Input>(
        _ keyPath: ReferenceWritableKeyPath<ViewDelegates, Delegate<View, Input, Void>>,
        _ closure: @escaping ((ListContext<View, Source>, Input)) -> Void
    ) -> Self {
        var setups = listContextSetups
        setups.append {
            let keyPath = Self.rootKeyPath.appending(path: keyPath)
            $0.set(keyPath) { (context, object, input, root) in
                closure((.init(context: context, listView: object, root: root), input))
            }
        }
        return .init(listContextSetups: setups, source: source, erasedGetter: erasedGetter)
    }

    func set<Input, Output, Index: ListIndex>(
        _ keyPath: ReferenceWritableKeyPath<ViewDelegates, IndexDelegate<View, Input, Output, Index>>,
        _ closure: @escaping ((ListIndexContext<View, Source, Index>, Input)) -> Output
    ) -> Self {
        var setups = listContextSetups
        setups.append {
            let keyPath = Self.rootKeyPath.appending(path: keyPath), path = $0[keyPath: keyPath].index
            $0.set(keyPath) {
                closure((.init(context: $0, listView: $1, index: $2[keyPath: path], offset: $4, root: $3), $2))
            }
        }
        return .init(listContextSetups: setups, source: source, erasedGetter: erasedGetter)
    }

    func set<Input, Index: ListIndex>(
        _ keyPath: ReferenceWritableKeyPath<ViewDelegates, IndexDelegate<View, Input, Void, Index>>,
        _ closure: @escaping ((ListIndexContext<View, Source, Index>, Input)) -> Void
    ) -> Self {
        var setups = listContextSetups
        setups.append {
            let keyPath = Self.rootKeyPath.appending(path: keyPath), path = $0[keyPath: keyPath].index
            $0.set(keyPath) {
                closure((.init(context: $0, listView: $1, index: $2[keyPath: path], offset: $4, root: $3), $2))
            }
        }
        return .init(listContextSetups: setups, source: source, erasedGetter: erasedGetter)
    }
}
