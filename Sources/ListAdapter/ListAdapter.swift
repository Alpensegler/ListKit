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
    
    var delegatesSetups: [(ListDelegates<Source>) -> Void] { get set }
    static var rootKeyPath: ReferenceWritableKeyPath<Delegates, ViewDelegates> { get }
    
    static func toContext(_ view: View, _ listContext: ListDelegates<Source>) -> Context
    
    static func toSectionContext(
        _ view: View,
        _ listContext: ListDelegates<Source>,
        section: Int
    ) -> SectionContext
    
    static func toItemContext(
        _ view: View,
        _ listContext: ListDelegates<Source>,
        path: PathConvertible
    ) -> ItemContext
    
    init(delegatesSetups: [(ListDelegates<Source>) -> Void], source: Source)
}

extension ListAdapter {
    init<OtherSource: DataSource>(
        _ dataSource: OtherSource
    ) where OtherSource.SourceBase == Source {
        self.init(delegatesSetups: [], source: dataSource.sourceBase)
    }

    init<OtherSource: ListAdapter>(
        _ dataSource: OtherSource
    ) where OtherSource.SourceBase == Source {
        self.init(delegatesSetups: dataSource.delegatesSetups, source: dataSource.sourceBase)
    }
    
    var sourceListCoordinator: ListCoordinator<Source> {
        let listCoordinator = coordinatorStorage.coordinator ?? makeListCoordinator()
        listCoordinator.stagingDelegatesSetups = delegatesSetups
        return listCoordinator
    }

    func set<Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<ViewDelegates, Delegate<View, Input, Output>>,
        _ closure: @escaping ((Context, Input)) -> Output
    ) -> Self {
        var mutableSelf = self
        mutableSelf.delegatesSetups.append {
            let keyPath = Self.rootKeyPath.appending(path: keyPath)
            $0.set(keyPath) { closure((Self.toContext($1, $0), $2)) }
        }
        return mutableSelf
    }

    func set<Input>(
        _ keyPath: ReferenceWritableKeyPath<ViewDelegates, Delegate<View, Input, Void>>,
        _ closure: @escaping ((Context, Input)) -> Void
    ) -> Self {
        var mutableSelf = self
        mutableSelf.delegatesSetups.append {
            let keyPath = Self.rootKeyPath.appending(path: keyPath)
            $0.set(keyPath) { closure((Self.toContext($1, $0), $2)) }
        }
        return mutableSelf
    }

    func set<Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<ViewDelegates, Delegate<View, Input, Output>>,
        _ closure: @escaping ((SectionContext, Input)) -> Output
    ) -> Self {
        var mutableSelf = self
        mutableSelf.delegatesSetups.append {
            let keyPath = Self.rootKeyPath.appending(path: keyPath)
            guard case let .index(path) = $0[keyPath: keyPath].index else { fatalError() }
            $0.set(keyPath) {
                closure((Self.toSectionContext($1, $0, section: $2[keyPath: path]), $2))
            }
        }
        return mutableSelf
    }

    func set<Input>(
        _ keyPath: ReferenceWritableKeyPath<ViewDelegates, Delegate<View, Input, Void>>,
        _ closure: @escaping ((SectionContext, Input)) -> Void
    ) -> Self {
        var mutableSelf = self
        mutableSelf.delegatesSetups.append {
            let keyPath = Self.rootKeyPath.appending(path: keyPath)
            guard case let .index(path) = $0[keyPath: keyPath].index else { fatalError() }
            $0.set(keyPath) {
                closure((Self.toSectionContext($1, $0, section: $2[keyPath: path]), $2))
            }
        }
        return mutableSelf
    }

    func set<Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<ViewDelegates, Delegate<View, Input, Output>>,
        _ closure: @escaping ((ItemContext, Input)) -> Output
    ) -> Self {
        var mutableSelf = self
        mutableSelf.delegatesSetups.append {
            let keyPath = Self.rootKeyPath.appending(path: keyPath)
            guard case let .indexPath(path) = $0[keyPath: keyPath].index else { fatalError() }
            $0.set(keyPath) { closure((Self.toItemContext($1, $0, path: $2[keyPath: path]), $2)) }
        }
        return mutableSelf
    }

    func set<Input>(
        _ keyPath: ReferenceWritableKeyPath<ViewDelegates, Delegate<View, Input, Void>>,
        _ closure: @escaping ((ItemContext, Input)) -> Void
    ) -> Self {
        var mutableSelf = self
        mutableSelf.delegatesSetups.append {
            let keyPath = Self.rootKeyPath.appending(path: keyPath)
            guard case let .indexPath(path) = $0[keyPath: keyPath].index else { fatalError() }
            $0.set(keyPath) { closure((Self.toItemContext($1, $0, path: $2[keyPath: path]), $2)) }
        }
        return mutableSelf
    }
}
