//
//  ListAdapter.swift
//  ListKit
//
//  Created by Frain on 2022/8/12.
//

// swiftlint:disable comment_spacing

import Foundation

public protocol ListAdapter: DataSource {
    associatedtype View = Never
    associatedtype List: ListAdapter = ListKit.List

    @ListBuilder<View>
    var list: List { get }
}

public struct List: ListAdapter {
    public var list: List { return self }
    public let listCoordinator: ListCoordinator
    public let listCoordinatorContext: ListCoordinatorContext
}

public extension ListAdapter {
    var listCoordinator: ListCoordinator { list.listCoordinator }
    var listCoordinatorContext: ListCoordinatorContext { list.listCoordinatorContext }
}

public extension ListAdapter where Self: AnyObject {
    var listCoordinatorContext: ListCoordinatorContext {
        listCoordinatorContext(from: list)
    }

    func performReload(
        animated: Bool = true,
        completion: ((ListView, Bool) -> Void)? = nil
    ) {
        _perform(reload: true, animated: animated, coordinatorGetter: self.list.listCoordinatorContext, completion: completion)
    }

    func performUpdate(animated: Bool = true, completion: ((ListView, Bool) -> Void)? = nil) {
        _perform(reload: false, animated: animated, coordinatorGetter: self.list.listCoordinatorContext, completion: completion)
    }
}

public extension ListAdapter {
    typealias ListContext = ListKit.ListContext<View>
    typealias ElementContext = ListIndexContext<View, IndexPath>
    typealias SectionContext = ListIndexContext<View, Int>

    typealias Function<Input, Output, Closure> = ListKit.Function<View, List, Input, Output, Closure>
    typealias ElementFunction<Input, Output, Closure> = IndexFunction<View, List, Input, Output, Closure, IndexPath>
    typealias SectionFunction<Input, Output, Closure> = IndexFunction<View, List, Input, Output, Closure, Int>

    func buildList<List>(@ListBuilder<Void> list: () -> List) -> List {
        list()
    }
}

public extension ListAdapter where Self: ListCoordinator, Self == List {
    var list: Self { self }
    var listCoordinator: ListCoordinator { self }
    var listCoordinatorContext: ListCoordinatorContext { .init(coordinator: self) }
}

public final class CoordinatorStorage: Hashable {
    var context: ListCoordinatorContext?
    var isObjectAssciated = false
    var contexts = [ObjectIdentifier: (() -> Delegate?, [IndexPath])]()
    weak var object: AnyObject?

    public init() { }

    init(_ object: AnyObject) {
        self.object = object
        self.isObjectAssciated = true
    }

    deinit {
        contexts.forEach {
            let (getter, contexts) = $0.value
            guard contexts.isEmpty else { return }
            getter()?.listView.resetDelegates(toNil: true)
        }
    }
}

public extension CoordinatorStorage {
    static func == (lhs: CoordinatorStorage, rhs: CoordinatorStorage) -> Bool {
        lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

private var storageKey: Void?

extension ListAdapter where Self: AnyObject {
    func _perform(
        reload: Bool,
        animated: Bool,
        coordinatorGetter: @autoclosure @escaping () -> ListCoordinatorContext,
        completion: ((ListView, Bool) -> Void)? = nil
    ) {
//        if update.isEmpty { return }
        guard let currentContext = coordinatorStorage.context else {
            return
        }
        let isMainThread = Thread.isMainThread
//        var update = update
        var context = coordinatorGetter()
        let work = {
            context = coordinatorGetter()
//            Log.log("----start-update: \(update.updateType)----")
//            if update.needSource, update.source == nil {
//                update.source = self.sourceBase.source
//                Log.log("from \(self.currentSource)")
//                Log.log("to   \(update.source!)")
//            }
        }
        _ = isMainThread ? work() : DispatchQueue.main.sync(execute: work)
        let update = reload ? .reload(change: nil) : currentContext.coordinator.performUpdate(to: context.coordinator)
        let afterWork: () -> Void = {
            defer { self.coordinatorStorage.context = context }
            guard !self.coordinatorStorage.contexts.isEmpty else { return }
            for (delegateGetter, positions) in self.coordinatorStorage.contexts.values {
                delegateGetter()?.perform(update: update, animated: animated, to: context, at: positions, completion: completion)
            }
        }
        _ = isMainThread ? afterWork() : DispatchQueue.main.sync(execute: afterWork)
    }

    func listCoordinatorContext(from list: DataSource) -> ListCoordinatorContext {
        coordinatorStorage.context ?? {
            var context = list.listCoordinatorContext
            context.storage = coordinatorStorage
            coordinatorStorage.context = context
            return context
        }()
    }

    var coordinatorStorage: CoordinatorStorage {
        get { Associator.getValue(key: &storageKey, from: self, initialValue: .init(self)) }
        set { Associator.set(value: newValue, key: &storageKey, to: self) }
    }
}
