//
//  ListAdapter.swift
//  ListKit
//
//  Created by Frain on 2022/8/12.
//

// swiftlint:disable comment_spacing

public protocol ListAdapter: DataSource {
    associatedtype View = Never
    associatedtype List = DataSource

    @ListBuilder
    var list: List { get }
}

public extension ListAdapter where List == DataSource {
    var listCoordinator: ListCoordinator { list.listCoordinator }
    var listCoordinatorContext: ListCoordinatorContext { list.listCoordinatorContext }
}

public extension ListAdapter where View: ListView {
    func apply(
        by listView: View,
        animated: Bool = true,
        completion: ((Bool) -> Void)? = nil
    ) {
        (listView as? DelegateSetuptable)?.listDelegate.setCoordinator(
            context: listCoordinatorContext,
            animated: animated,
            completion: completion
        )
    }
}

@resultBuilder
public enum ListBuilder { }

public extension ListBuilder {
    static func buildPartialBlock<D: DataSource>(first: D) -> D {
        first
    }

    static func buildPartialBlock<F: DataSource, S: DataSource>(accumulated: F, next: S) -> TupleSources<F, S> {
        .init(list: [accumulated.listCoordinatorContext, next.listCoordinatorContext])
    }

    static func buildPartialBlock<F: DataSource, S: DataSource, N: DataSource>(accumulated: TupleSources<F, S>, next: N) -> TupleSources<TupleSources<F, S>, N> {
        .init(list: accumulated.list + [next.listCoordinatorContext])
    }

    static func buildEither<T: DataSource, F: DataSource>(first component: T) -> ConditionalSources<T, F> {
        .init(list: .first(component))
    }

    static func buildEither<T: DataSource, F: DataSource>(second component: F) -> ConditionalSources<T, F> {
        .init(list: .second(component))
    }

    static func buildArray<D: DataSource>(_ components: [D]) -> DataSources<[D], D> {
        .init(components)
    }

    static func buildOptional<S: DataSource>(_ content: S?) -> S? {
        content
    }
}

//extension ListAdaptation: ModelCachedDataSource where Source: ModelCachedDataSource {
//    public typealias ModelCache = Source.ModelCache
//
//    public var modelCached: ModelCached<Source.SourceBase, Source.ModelCache> { source.modelCached }
//    public var base: ListAdaptation<Source.SourceBase.AdapterBase, View> {
//        .init(source.sourceBase.adapterBase, listDelegate: listDelegate)
//    }
//}
