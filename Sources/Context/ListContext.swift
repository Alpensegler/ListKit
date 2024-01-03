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

public struct ListContext<View>: Context {
    public let listView: View
    let context: ListCoordinatorContext
}

extension ListContext {
    init(
        view: AnyObject,
        context: ListCoordinatorContext
    ) {
        self.init(listView: view as! View, context: context)
    }
}

public struct ListIndexContext<View, Index>: Context {
    public let listView: View
    public let index: Index
    public let rawIndex: Index
    let context: ListCoordinatorContext
}

extension ListIndexContext {
    init(
        view: AnyObject,
        index: Index,
        rawIndex: Index,
        context: ListCoordinatorContext
    ) {
        self.init(
            listView: view as! View,
            index: index,
            rawIndex: rawIndex,
            context: context
        )
    }
}

public extension ListIndexContext where Index == Int {
    var section: Int { index }
}

public extension ListIndexContext where Index == IndexPath {
    var section: Int { index.section }
    var item: Int { index.item }
}

extension ListIndexContext where Index == IndexPath {
    func element<List: TypedListAdapter>(for type: List.Type) -> List.Element {
        (context.coordinator as! List).element(at: self)
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
