//
//  ScrollListAdapter.swift
//  ListKit
//
//  Created by Frain on 2019/12/5.
//

public protocol ScrollListAdapter: DataSource {
    var scrollList: ScrollList<AdapterBase> { get }
}

public extension ScrollListAdapter {
    var scrollList: ScrollList<AdapterBase> { ScrollList(adapterBase) }
}

@propertyWrapper
@dynamicMemberLookup
public class ScrollList<Source: DataSource>: ScrollListAdapter, UpdatableDataSource
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

    public var scrollList: ScrollList<Source> { self }
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

    required init<OtherSource: DataSource>(
        _ source: OtherSource,
        options: ListOptions = .init()
    ) where Source == AnySources {
        self.source = AnySources(source, options: options)
        self.listDelegate = .init()
    }

    required init(_ source: Source) {
        self.source = source
        self.listDelegate = source.listDelegate
    }

    required init(_ source: Source, listDelegate: ListDelegate) {
        self.source = source
        self.listDelegate = listDelegate
    }
}

extension ScrollList: ModelCachedDataSource where Source: ModelCachedDataSource {
    public typealias ModelCache = Source.ModelCache

    public var modelCached: ModelCached<Source.SourceBase, Source.ModelCache> { source.modelCached }
}
