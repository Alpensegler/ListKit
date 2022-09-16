//
//  ListCoordinatorContext.swift
//  ListKit
//
//  Created by Frain on 2020/6/8.
//

import Foundation

protocol CoordinatorContext: AnyObject {
    var valid: Bool { get }
//    var modelCaches: ContiguousArray<ContiguousArray<Any?>> { get set }
//    var modelNestedCache: ContiguousArray<ContiguousArray<((Any) -> Void)?>> { get set }

    func isCoordinator(_ coordinator: AnyObject) -> Bool

    func numbersOfSections() -> Int
    func numbersOfModel(in section: Int) -> Int

    func contain(selector: Selector) -> Bool

    func apply<Input, Output>(
        _ selector: Selector,
        root: CoordinatorContext,
        view: AnyObject,
        with input: Input
    ) -> Output?

    func apply<Input, Output, Index: ListIndex>(
        _ selector: Selector,
        root: CoordinatorContext,
        view: AnyObject,
        with input: Input,
        index: Index
    ) -> Output?

    func perform(updates: BatchUpdates?, animated: Bool, completion: ((ListView, Bool) -> Void)?)
}

public final class ListCoordinatorContext<SourceBase: DataSource>: CoordinatorContext
where SourceBase.SourceBase == SourceBase {
    typealias Model = SourceBase.Model
    typealias Caches<Cache> = ContiguousArray<ContiguousArray<Cache?>>

    let listCoordinator: ListCoordinator<SourceBase>

//    var _modelCaches: Caches<Any>?
//    var _modelNestedCache: Caches<((Any) -> Void)>?

    var listDelegate = ListDelegate()

    var index = 0
    var isSectioned = true
    var listViewGetter: (() -> ListView?)?
    var resetDelegates: (() -> Void)?
    var update: ((Int, CoordinatorUpdate) -> [(CoordinatorContext, CoordinatorUpdate)]?)?
    var contextAtIndex: ((Int, IndexPath, ListView) -> [(IndexPath, CoordinatorContext)])?

    lazy var extraSelectors = listCoordinator.configExtraSelector(delegate: listDelegate)
        ?? listDelegate.extraSelectors

    var listView: ListView? { listViewGetter?() }
    var valid: Bool {
        guard let storage = listCoordinator.storage else { return true }
        return !storage.isObjectAssciated || storage.object != nil
    }

//    var modelCaches: Caches<Any> {
//        get { cachesOrCreate(&_modelCaches) }
//        set { _modelCaches = newValue }
//    }
//
//    var modelNestedCache: Caches<((Any) -> Void)> {
//        get { cachesOrCreate(&_modelNestedCache) }
//        set { _modelNestedCache = newValue }
//    }

    init(_ coordinator: ListCoordinator<SourceBase>, listDelegate: ListDelegate = .init()) {
        self.listCoordinator = coordinator
        self.listDelegate = listDelegate
        coordinator.listContexts.append(.init(context: self))
    }

    func context(with listDelegate: ListDelegate) -> Self {
        self.listDelegate.formUnion(delegate: listDelegate)
        return self
    }

    func isCoordinator(_ coordinator: AnyObject) -> Bool { self.listCoordinator === coordinator }

    func reconfig() { }
    func numbersOfSections() -> Int { listCoordinator.numbersOfSections() }
    func numbersOfModel(in section: Int) -> Int { listCoordinator.numbersOfModel(in: section) }

    // Selectors
    @discardableResult
    func apply<Input, Output>(
        _ selector: Selector,
        root: CoordinatorContext,
        view: AnyObject,
        with input: Input
    ) -> Output? {
        listCoordinator.apply(selector, for: self, root: root, view: view, with: input)
    }

    @discardableResult
    func apply<Input, Output, Index: ListIndex>(
        _ selector: Selector,
        root: CoordinatorContext,
        view: AnyObject,
        with input: Input,
        index: Index
    ) -> Output? {
        listCoordinator.apply(selector, for: self, root: root, view: view, with: input, index: index, .zero)
    }

    func contain(selector: Selector) -> Bool {
        listDelegate.contains(selector) || extraSelectors.contains(selector)
    }

//    func cachesOrCreate<Cache>(_ caches: inout Caches<Cache>?) -> Caches<Cache> {
//        caches.or((0..<numbersOfSections()).mapContiguous {
//            (0..<numbersOfModel(in: $0)).mapContiguous { _ in nil }
//        })
//    }

    func perform(updates: BatchUpdates?, animated: Bool, completion: ((ListView, Bool) -> Void)?) {
        guard let list = listView else { return }
        guard let updates = updates else {
            completion?(list, false)
            return
        }
        switch updates {
        case let .reload(change: change):
//            (_modelCaches, _modelNestedCache) = (nil, nil)
            change?()
            list.reloadSynchronously(animated: animated)
            completion?(list, true)
        case let .batch(batchUpdates):
            for (offset, batchUpdate) in batchUpdates.enumerated() {
                let isLast = offset == batchUpdates.count - 1
                Log.log("---batch-update-isLast: \(isLast)---")
                Log.log(batchUpdate.description)
                let completion: ((Bool) -> Void)? = isLast ? { [weak list] finish in
                    list.map { completion?($0, finish) }
                } : nil
                list.perform({
//                    switch (_modelCaches != nil, _modelNestedCache != nil) {
//                    case (true, true):
//                        batchUpdate.apply(caches: &modelCaches, countIn: numbersOfModel(in:)) {
//                            $0.apply(caches: &modelNestedCache, countIn: numbersOfModel(in:))
//                        }
//                    case (true, false):
//                        batchUpdate.apply(caches: &modelCaches, countIn: numbersOfModel(in:))
//                    case (false, true):
//                        batchUpdate.apply(caches: &modelNestedCache, countIn: numbersOfModel(in:))
//                    case (false, false):
//                        batchUpdate.applyData()
//                    }
                    if let selectors = listCoordinator.configExtraSelector(delegate: listDelegate) {
                        extraSelectors = selectors
                        listView?.resetDelegates(toNil: false)
                    }
                    batchUpdate.apply(by: list)
                }, animated: animated, completion: completion)
            }
        }
    }
}
