//
//  ListContext.swift
//  ListKit
//
//  Created by Frain on 2020/8/2.
//

// swiftlint:disable comment_spacing

import Foundation

public protocol Context {
    associatedtype View

    var listView: View { get }
}

public struct ListContext<View, Model>: Context {
    public let listView: View
    let context: ListCoordinatorContext<Model>
    let root: CoordinatorContext
}

extension ListContext {
    init(
        view: AnyObject,
        context: ListCoordinatorContext<Model>,
        root: CoordinatorContext
    ) {
        self.init(listView: view as! View, context: context, root: root)
    }
}

public struct ListIndexContext<View, Model, Index>: Context {
    public let listView: View
    public let index: Index
    public let offset: Index
    let context: ListCoordinatorContext<Model>
    let root: CoordinatorContext
}

extension ListIndexContext {
    init(
        view: AnyObject,
        index: Index,
        offset: Index,
        context: ListCoordinatorContext<Model>,
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
    typealias ListContext = ListKit.ListContext<View, Model>
    typealias ListModelContext = ListIndexContext<View, Model, IndexPath>
    typealias ListSectionContext = ListIndexContext<View, Model, Int>

    typealias Function<Input, Output, Closure> = ListDelegate.Function<View, Model, Input, Output, Closure>
    typealias ModelFunction<Input, Output, Closure> = ListDelegate.IndexFunction<View, Model, Input, Output, Closure, IndexPath>
    typealias SectionFunction<Input, Output, Closure> = ListDelegate.IndexFunction<View, Model, Input, Output, Closure, Int>
}

public extension ListIndexContext where Index == Int {
    var section: Int { index - offset }
}

public extension ListIndexContext where Index == IndexPath {
    var section: Int { index.section - offset.section }
    var item: Int { index.item - offset.item }

    var model: Model {
        context.listCoordinator.model(at: index.offseted(offset, plus: false))
    }
}

//public extension ListIndexContext where Base: ModelCachedDataSource, Index == IndexPath {
//    var modelCache: Base.ModelCache { cache() }
//}
//
//extension ListIndexContext where Index == IndexPath {
//    func setNestedCache(update: @escaping (Any) -> Void) {
//        root.modelNestedCache[index.section][index.item] = update
//    }
//
//    func cache<Cache>() -> Cache {
//        if let cache = root.modelCaches[index.section][index.item] as? Cache { return cache }
//        return context.listCoordinator.cache(
//            for: &root.modelCaches[index.section][index.item],
//            at: index,
//            in: context.listDelegate
//        )
//    }
//}
