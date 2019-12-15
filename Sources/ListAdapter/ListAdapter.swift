//
//  ListAdapter.swift
//  ListKit
//
//  Created by Frain on 2019/12/16.
//

protocol ListAdapter: UpdatableDataSource where Source == SourceBase {
    associatedtype View: AnyObject
    associatedtype Value: AnyObject
    associatedtype Context
    associatedtype SectionContext
    associatedtype ItemContext
    
    var contextSetups: [(ListContext<Source>) -> Void] { get set }
    static var rootKeyPath: ReferenceWritableKeyPath<Delegates, Value> { get }
    
    static func toContext(_ view: View, _ listContext: ListContext<Source>) -> Context
    static func toSectionContext(_ view: View, _ listContext: ListContext<Source>, section: Int) -> SectionContext
    static func toItemContext(_ view: View, _ listContext: ListContext<Source>, path: PathConvertible) -> ItemContext
    
    init(contextSetups: [(ListContext<Source>) -> Void], source: Source)
}

extension ListAdapter {
    init<OtherSource: DataSource>(_ dataSource: OtherSource) where OtherSource.SourceBase == Source {
        self.init(contextSetups: [], source: dataSource.sourceBase)
    }

    init<OtherSource: ListAdapter>(_ dataSource: OtherSource) where OtherSource.SourceBase == Source {
        self.init(contextSetups: dataSource.contextSetups, source: dataSource.sourceBase)
    }
    
    var sourceListCoordinator: ListCoordinator<Source> {
        let listCoordinator = coordinatorStorage.coordinator ?? makeListCoordinator()
        listCoordinator.stagingContextSetups = contextSetups
        return listCoordinator
    }

    func set<Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<Value, Delegate<View, Input, Output>>,
        _ closure: @escaping ((Context, Input)) -> Output
    ) -> Self {
        var collectionList = self
        collectionList.contextSetups.append {
            let keyPath = Self.rootKeyPath.appending(path: keyPath)
            $0.set(keyPath) { closure((Self.toContext($1, $0), $2)) }
        }
        return collectionList
    }

    func set<Input>(
        _ keyPath: ReferenceWritableKeyPath<Value, Delegate<View, Input, Void>>,
        _ closure: @escaping ((Context, Input)) -> Void
    ) -> Self {
        var collectionList = self
        collectionList.contextSetups.append {
            let keyPath = Self.rootKeyPath.appending(path: keyPath)
            $0.set(keyPath) { closure((Self.toContext($1, $0), $2)) }
        }
        return collectionList
    }

    func set<Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<Value, Delegate<View, Input, Output>>,
        _ closure: @escaping ((SectionContext, Input)) -> Output
    ) -> Self {
        var collectionList = self
        collectionList.contextSetups.append {
            let keyPath = Self.rootKeyPath.appending(path: keyPath)
            guard case let .index(path) = $0[keyPath: keyPath].index else { fatalError() }
            $0.set(keyPath) { closure((Self.toSectionContext($1, $0, section: $2[keyPath: path]), $2)) }
        }
        return collectionList
    }

    func set<Input>(
        _ keyPath: ReferenceWritableKeyPath<Value, Delegate<View, Input, Void>>,
        _ closure: @escaping ((SectionContext, Input)) -> Void
    ) -> Self {
        var collectionList = self
        collectionList.contextSetups.append {
            let keyPath = Self.rootKeyPath.appending(path: keyPath)
            guard case let .index(path) = $0[keyPath: keyPath].index else { fatalError() }
            $0.set(keyPath) { closure((Self.toSectionContext($1, $0, section: $2[keyPath: path]), $2)) }
        }
        return collectionList
    }

    func set<Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<Value, Delegate<View, Input, Output>>,
        _ closure: @escaping ((ItemContext, Input)) -> Output
    ) -> Self {
        var collectionList = self
        collectionList.contextSetups.append {
            let keyPath = Self.rootKeyPath.appending(path: keyPath)
            guard case let .indexPath(path) = $0[keyPath: keyPath].index else { fatalError() }
            $0.set(keyPath) { closure((Self.toItemContext($1, $0, path: $2[keyPath: path]), $2)) }
        }
        return collectionList
    }

    func set<Input>(
        _ keyPath: ReferenceWritableKeyPath<Value, Delegate<View, Input, Void>>,
        _ closure: @escaping ((ItemContext, Input)) -> Void
    ) -> Self {
        var collectionList = self
        collectionList.contextSetups.append {
            let keyPath = Self.rootKeyPath.appending(path: keyPath)
            guard case let .indexPath(path) = $0[keyPath: keyPath].index else { fatalError() }
            $0.set(keyPath) { closure((Self.toItemContext($1, $0, path: $2[keyPath: path]), $2)) }
        }
        return collectionList
    }
}
