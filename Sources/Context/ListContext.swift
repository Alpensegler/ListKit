//
//  ListContext.swift
//  ListKit
//
//  Created by Frain on 2020/8/2.
//

import Foundation

@dynamicMemberLookup
public protocol Context {
    associatedtype Base: DataSource
    associatedtype View

    var source: Base.SourceBase.Source { get }
    var listView: View { get }
}

public struct ListContext<View, Base: DataSource>: Context {
    public let listView: View
    let context: ListCoordinatorContext<Base.SourceBase>
    let root: CoordinatorContext

    public var source: Base.SourceBase.Source { context.listCoordinator.source }
}

extension ListContext {
    init(
        view: AnyObject,
        context: ListCoordinatorContext<Base.SourceBase>,
        root: CoordinatorContext
    ) {
        self.init(listView: view as! View, context: context, root: root)
    }
}

public struct ListIndexContext<View, Base: DataSource, Index>: Context {
    public let listView: View
    public let index: Index
    public let offset: Index
    let context: ListCoordinatorContext<Base.SourceBase>
    let root: CoordinatorContext

    public var source: Base.SourceBase.Source { context.listCoordinator.source }
}

extension ListIndexContext {
    init(
        view: AnyObject,
        index: Index,
        offset: Index,
        context: ListCoordinatorContext<Base.SourceBase>,
        root: CoordinatorContext
    ) {
        self.init(
            listView: view as! View,
            index: index,
            offset: offset,
            context: context,
            root: root
        )
    }
}

public extension ListAdapter {
    typealias ListContext = ListKit.ListContext<View, Self>
    typealias ListModelContext = ListIndexContext<View, Self, IndexPath>
    typealias ListSectionContext = ListIndexContext<View, Self, Int>

    typealias Function<Input, Output, Closure> = ListDelegate.Function<View, Self, Input, Output, Closure>
    typealias ModelFunction<Input, Output, Closure> = ListDelegate.IndexFunction<View, Self, Input, Output, Closure, IndexPath>
    typealias SectionFunction<Input, Output, Closure> = ListDelegate.IndexFunction<View, Self, Input, Output, Closure, Int>
}

public extension Context {
    subscript<Value>(dynamicMember keyPath: KeyPath<Base.SourceBase.Source, Value>) -> Value {
        source[keyPath: keyPath]
    }
}

public extension ListIndexContext where Index == Int {
    var section: Int { index - offset }
}

public extension ListIndexContext where Index == IndexPath {
    var section: Int { index.section - offset.section }
    var item: Int { index.item - offset.item }

    var model: Base.SourceBase.Model {
        context.listCoordinator.model(at: index.offseted(offset, plus: false))
    }
}

//public extension ListIndexContext where Base: ModelCachedDataSource, Index == IndexPath {
//    var modelCache: Base.ModelCache { cache() }
//}

extension ListIndexContext where Index == IndexPath {
    func setNestedCache(update: @escaping (Any) -> Void) {
        root.modelNestedCache[index.section][index.item] = update
    }

    func cache<Cache>() -> Cache {
        if let cache = root.modelCaches[index.section][index.item] as? Cache { return cache }
        return context.listCoordinator.cache(
            for: &root.modelCaches[index.section][index.item],
            at: index,
            in: context.listDelegate
        )
    }
}
