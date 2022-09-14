//
//  ListAdapter.swift
//  ListKit
//
//  Created by Frain on 2022/8/12.
//

public protocol ListAdapter: DataSource {
    associatedtype View: ListView = TableView

    @ListBuilder<AdapterBase, View>
    var list: ListAdaptation<AdapterBase, View> { get }
}

@propertyWrapper
@dynamicMemberLookup
public struct ListAdaptation<Source: DataSource, View: ListView>: ListAdapter
where Source.AdapterBase == Source {
    public typealias Model = Source.Model
    public typealias SourceBase = Source.SourceBase
    public typealias AdapterBase = Source

    public var source: Source
    public var sourceBase: SourceBase { source.sourceBase }
    public var adapterBase: Source { source }

    public var listUpdate: ListUpdate<SourceBase>.Whole { source.listUpdate }
    public var listDiffer: ListDiffer<SourceBase> { source.listDiffer }
    public var listOptions: ListOptions { source.listOptions }

    public var listDelegate: ListDelegate
    public var listCoordinatorContext: ListCoordinatorContext<SourceBase> {
        source.listCoordinatorContext.context(with: listDelegate)
    }

    public lazy var listCoordinator = source.listCoordinator
    public lazy var coordinatorStorage = listCoordinator.storage.or({
        let storage = CoordinatorStorage<SourceBase>()
        listCoordinator.storage = storage
        return storage
    }())

    public var list: ListAdaptation<Source, View> { self }

    public var wrappedValue: Source {
        get { source }
        set { source = newValue }
    }

    public subscript<Value>(dynamicMember path: KeyPath<Source, Value>) -> Value {
        source[keyPath: path]
    }

    public subscript<Value>(dynamicMember path: WritableKeyPath<Source, Value>) -> Value {
        get { source[keyPath: path] }
        set { source[keyPath: path] = newValue }
    }

    init<OtherSource: DataSource>(
        _ source: OtherSource,
        options: ListOptions = .init()
    ) where Source == AnySources {
        self.source = AnySources(source, options: options)
        self.listDelegate = .init()
    }

    init(_ source: Source) {
        self.source = source
        self.listDelegate = source.listDelegate
    }

    init(_ source: Source, listDelegate: ListDelegate) {
        self.source = source
        self.listDelegate = listDelegate
    }
}

public extension ListAdapter {
    @discardableResult
    func apply(
        by listView: View,
        update: ListUpdate<SourceBase>.Whole?,
        animated: Bool = true,
        completion: ((Bool) -> Void)? = nil
    ) -> ListAdaptation<AdapterBase, View> {
        (listView as? DelegateSetuptable)?.listDelegate.setCoordinator(
            context: listCoordinatorContext,
            update: update,
            animated: animated,
            completion: completion
        )
        return list
    }

    @discardableResult
    func apply(
        by listView: View,
        animated: Bool = true,
        completion: ((Bool) -> Void)? = nil
    ) -> ListAdaptation<AdapterBase, View> {
        apply(by: listView, update: listUpdate, animated: animated, completion: completion)
    }
}

extension ListAdaptation: ModelCachedDataSource where Source: ModelCachedDataSource {
    public typealias ModelCache = Source.ModelCache

    public var modelCached: ModelCached<Source.SourceBase, Source.ModelCache> { source.modelCached }
    public var base: ListAdaptation<Source.SourceBase.AdapterBase, View> {
        .init(source.sourceBase.adapterBase, listDelegate: listDelegate)
    }
}
