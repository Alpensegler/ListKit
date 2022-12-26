//
//  ListAdapter.swift
//  ListKit
//
//  Created by Frain on 2022/8/12.
//

// swiftlint:disable comment_spacing

public protocol ListAdapter<Model, View>: DataSource {
    associatedtype View: ListView = TableView

    @ListBuilder<Model, View>
    var list: ListAdaptation<Model, View> { get }
}

public extension ListAdapter {
    var source: any DataSource<Model> { return list }
    var listCoordinatorContext: ListCoordinatorContext<Model> { list.listCoordinatorContext }
}

public extension ListAdapter where Self: UpdatableDataSource {
    var listCoordinatorContext: ListCoordinatorContext<Model> {
        ListCoordinatorContext(listCoordinator).context(with: listDelegate)
    }
}

extension ListAdapter {
    var listGetter: ListAdaptation<Model, View> { return list }
    var listDelegate: ListDelegate { list.listDelegate }
}

public struct ListAdaptation<Model, View: ListView>: ListAdapter {
    public var source: any DataSource<Model>

//    public var listUpdate: ListUpdate<SourceBase>.Whole { source.listUpdate }
//    public var listDiffer: ListDiffer<SourceBase> { source.listDiffer }
//    public var listOptions: ListOptions { source.listOptions }

    public var listDelegate: ListDelegate
    public var listCoordinatorContext: ListCoordinatorContext<Model> {
        source.listCoordinatorContext.context(with: listDelegate)
    }

    public var listCoordinator: ListCoordinator<Model> { source.listCoordinator }
    public var list: ListAdaptation<Model, View> { return self }

//    init<OtherSource: DataSource>(
//        _ source: OtherSource,
//        options: ListOptions = .init()
//    ) where Source == AnySources {
//        self.source = AnySources(source, options: options)
//        self.listDelegate = .init()
//    }

    init(_ source: any DataSource<Model>) {
        self.source = source
        self.listDelegate = .init()
    }

    init(_ source: any DataSource<Model>, listDelegate: ListDelegate) {
        self.source = source
        self.listDelegate = listDelegate
    }
}

public extension ListAdapter {
//    @discardableResult
    func apply(
        by listView: View,
//        update: ListUpdate<SourceBase>.Whole?,
        animated: Bool = true,
        completion: ((Bool) -> Void)? = nil
//    ) -> ListAdaptation<AdapterBase, View> {
    ) {
        (listView as? DelegateSetuptable)?.listDelegate.setCoordinator(
            context: listCoordinatorContext,
//            update: update,
            animated: animated,
            completion: completion
        )
//        return list
    }

//    @discardableResult
//    func apply(
//        by listView: View,
//        animated: Bool = true,
//        completion: ((Bool) -> Void)? = nil
//    ) -> ListAdaptation<Model, View> {
//        apply(by: listView, update: listUpdate, animated: animated, completion: completion)
//    }
}

//extension ListAdaptation: ModelCachedDataSource where Source: ModelCachedDataSource {
//    public typealias ModelCache = Source.ModelCache
//
//    public var modelCached: ModelCached<Source.SourceBase, Source.ModelCache> { source.modelCached }
//    public var base: ListAdaptation<Source.SourceBase.AdapterBase, View> {
//        .init(source.sourceBase.adapterBase, listDelegate: listDelegate)
//    }
//}
