//
//  ListAdapter.swift
//  ListKit
//
//  Created by Frain on 2019/12/16.
//

protocol ListAdapter: UpdatableDataSource where Source == SourceBase {
    associatedtype View: AnyObject
    associatedtype ViewDelegates: AnyObject
    associatedtype Context
    associatedtype SectionContext
    associatedtype ItemContext
    associatedtype ErasedType
    
    var erasedGetter: (Self) -> ErasedType { get }
    var coordinatorSetups: [(ListCoordinator<Source>) -> Void] { get }
    static var defaultErasedGetter: (Self) -> ErasedType { get }
    static var rootKeyPath: ReferenceWritableKeyPath<Coordinator, ViewDelegates> { get }
    
    static func toContext(_ view: View, _ coordinator: ListCoordinator<Source>) -> Context
    
    static func toSectionContext(
        _ view: View,
        _ coordinator: ListCoordinator<Source>,
        section: Int
    ) -> SectionContext
    
    static func toItemContext(
        _ view: View,
        _ coordinator: ListCoordinator<Source>,
        path: Path
    ) -> ItemContext
    
    init(
        coordinatorSetups: [(ListCoordinator<Source>) -> Void],
        source: Source,
        erasedGetter: @escaping (Self) -> ErasedType
    )
}

final class ListAdapterStorage<Source: DataSource> where Source.SourceBase == Source {
    var makeListCoordinator: () -> ListCoordinator<Source> = { fatalError() }
    
    lazy var listCoordinator = makeListCoordinator()
    lazy var coordinatorStorage = listCoordinator.storage ?? {
        let storage = CoordinatorStorage<Source>()
        storage.coordinators.append(listCoordinator)
        return storage
    }()
}

extension ListAdapter {
    init<OtherSource: DataSource>(
        _ dataSource: OtherSource,
        erasedGetter: @escaping (Self) -> ErasedType = Self.defaultErasedGetter
    ) where OtherSource.SourceBase == Source {
        self.init(coordinatorSetups: [], source: dataSource.sourceBase, erasedGetter: erasedGetter)
    }

    init<OtherSource: ListAdapter>(
        _ dataSource: OtherSource
    ) where OtherSource.SourceBase == Source {
        self.init(
            coordinatorSetups: dataSource.coordinatorSetups,
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
    var cacheFromItem: ((Item) -> Any)? { nil }
    
    nonmutating func makeCoordinator() -> ListCoordinator<Source> {
        let coordinator = sourceBase.makeListCoordinator()
        coordinatorSetups.forEach { $0(coordinator) }
        coordinator.cacheFromItem = cacheFromItem
        return coordinator
    }

    func set<Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<ViewDelegates, Delegate<View, Input, Output>>,
        _ closure: @escaping ((Context, Input)) -> Output
    ) -> Self {
        var setups = coordinatorSetups
        setups.append {
            let keyPath = Self.rootKeyPath.appending(path: keyPath)
            $0.set(keyPath) { closure((Self.toContext($1, $0), $2)) }
        }
        return .init(coordinatorSetups: setups, source: source, erasedGetter: erasedGetter)
    }

    func set<Input>(
        _ keyPath: ReferenceWritableKeyPath<ViewDelegates, Delegate<View, Input, Void>>,
        _ closure: @escaping ((Context, Input)) -> Void
    ) -> Self {
        var setups = coordinatorSetups
        setups.append {
            let keyPath = Self.rootKeyPath.appending(path: keyPath)
            $0.set(keyPath) { closure((Self.toContext($1, $0), $2)) }
        }
        return .init(coordinatorSetups: setups, source: source, erasedGetter: erasedGetter)
    }

    func set<Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<ViewDelegates, Delegate<View, Input, Output>>,
        _ closure: @escaping ((SectionContext, Input)) -> Output
    ) -> Self {
        var setups = coordinatorSetups
        setups.append {
            let keyPath = Self.rootKeyPath.appending(path: keyPath)
            guard case let .index(path) = $0[keyPath: keyPath].index else { fatalError() }
            $0.set(keyPath) {
                closure((Self.toSectionContext($1, $0, section: $2[keyPath: path]), $2))
            }
        }
        return .init(coordinatorSetups: setups, source: source, erasedGetter: erasedGetter)
    }

    func set<Input>(
        _ keyPath: ReferenceWritableKeyPath<ViewDelegates, Delegate<View, Input, Void>>,
        _ closure: @escaping ((SectionContext, Input)) -> Void
    ) -> Self {
        var setups = coordinatorSetups
        setups.append {
            let keyPath = Self.rootKeyPath.appending(path: keyPath)
            guard case let .index(path) = $0[keyPath: keyPath].index else { fatalError() }
            $0.set(keyPath) {
                closure((Self.toSectionContext($1, $0, section: $2[keyPath: path]), $2))
            }
        }
        return .init(coordinatorSetups: setups, source: source, erasedGetter: erasedGetter)
    }

    func set<Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<ViewDelegates, Delegate<View, Input, Output>>,
        _ closure: @escaping ((ItemContext, Input)) -> Output
    ) -> Self {
        var setups = coordinatorSetups
        setups.append {
            let keyPath = Self.rootKeyPath.appending(path: keyPath)
            guard case let .indexPath(path) = $0[keyPath: keyPath].index else { fatalError() }
            $0.set(keyPath) { closure((Self.toItemContext($1, $0, path: $2[keyPath: path]), $2)) }
        }
        return .init(coordinatorSetups: setups, source: source, erasedGetter: erasedGetter)
    }

    func set<Input>(
        _ keyPath: ReferenceWritableKeyPath<ViewDelegates, Delegate<View, Input, Void>>,
        _ closure: @escaping ((ItemContext, Input)) -> Void
    ) -> Self {
        var setups = coordinatorSetups
        setups.append {
            let keyPath = Self.rootKeyPath.appending(path: keyPath)
            guard case let .indexPath(path) = $0[keyPath: keyPath].index else { fatalError() }
            $0.set(keyPath) { closure((Self.toItemContext($1, $0, path: $2[keyPath: path]), $2)) }
        }
        return .init(coordinatorSetups: setups, source: source, erasedGetter: erasedGetter)
    }
}
