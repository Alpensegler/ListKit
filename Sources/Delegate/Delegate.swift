//
//  ListDelegate.swift
//  ListKit
//
//  Created by Frain on 2020/1/1.
//

import Foundation

import UIKit

final class Delegate: NSObject {
    unowned let listView: SetuptableListView
    var context: ListCoordinatorContext!
    var coordinator: ListCoordinator { context.coordinator }
    var valid: Bool {
        guard let storage = context.storage else { return true }
        return !storage.isObjectAssciated || storage.object != nil
    }

//    weak var currentCoordinatorUpdate: ListCoordinatorUpdate?
//    typealias Caches<Cache> = ContiguousArray<ContiguousArray<Cache?>>
//    var _modelCaches: Caches<Any>?
//    var _modelNestedCache: Caches<((Any) -> Void)>?
//    var modelCaches: Caches<Any> {
//        get { cachesOrCreate(&_modelCaches) }
//        set { _modelCaches = newValue }
//    }
//
//    var modelNestedCache: Caches<((Any) -> Void)> {
//        get { cachesOrCreate(&_modelNestedCache) }
//        set { _modelNestedCache = newValue }
//    }

    init(_ listView: SetuptableListView) {
        self.listView = listView
    }

    override func responds(to aSelector: Selector!) -> Bool {
        guard allSelectors.contains(aSelector) else { return super.responds(to: aSelector) }
        return aSelector.map {
            context.selectors.contains($0) || coordinator.selectors?.contains($0) == true
        } == true
    }

//    func cachesOrCreate<Cache>(_ caches: inout Caches<Cache>?) -> Caches<Cache> {
//        caches.or((0..<numbersOfSections()).mapContiguous {
//            (0..<numbersOfModel(in: $0)).mapContiguous { _ in nil }
//        })
//    }
}

extension Delegate {
    var delegateGetter: () -> Delegate? {
        { [weak listView, weak self] in
            guard let self = self, let listView = listView else { return nil }
            return listView.isDelegate(self) ? self : nil
        }
    }

    func setCoordinator(
        context: ListCoordinatorContext,
//        update: ListUpdate<SourceBase>.Whole?,
        animated: Bool,
        completion: ((Bool) -> Void)?
    ) {
        var context = context
        config(context: &context)
        self.context = context
        if !listView.isDelegate(self) { listView.setup(with: self) }
//        let updatable = isDelegate && rawCoordinator.map {
//            coordinator.update(from: $0, animated: animated, completion: completion)
//        } ?? false
//        if updatable { return }
//        if update != nil {
        listView.reloadSynchronously(animated: animated)
//        }
        completion?(true)
    }

    func perform(update: BatchUpdates, animated: Bool, to context: ListCoordinatorContext, at positions: [IndexPath], completion: ((ListView, Bool) -> Void)?) {
        var finalContext = self.context!
        var update = update
        
        for position in positions {
            if position.isEmpty {
                finalContext = context
            } else {
                finalContext.coordinator.performUpdate(update: &update, at: position, to: context)
            }
        }

        config(context: &finalContext)
        perform(
            to: finalContext,
            updates: update,
            shouldRestDelegate: finalContext.selectors != self.context.selectors,
            animated: animated,
            completion: completion
        )
    }

    func perform(to context: ListCoordinatorContext, updates: BatchUpdates?, shouldRestDelegate: Bool, animated: Bool, completion: ((ListView, Bool) -> Void)?) {
        guard let updates = updates else {
            completion?(listView, false)
            return
        }
        switch updates {
        case let .reload(change: change):
//            (_modelCaches, _modelNestedCache) = (nil, nil)
            self.context = context
            change?()
            if shouldRestDelegate {
                listView.resetDelegates(toNil: false)
            }
            listView.reloadSynchronously(animated: animated)
            completion?(listView, true)
        case let .batch(batchUpdate):
            Log.log(batchUpdate.description)
            listView.perform({
//                switch (_modelCaches != nil, _modelNestedCache != nil) {
//                case (true, true):
//                    batchUpdate.apply(caches: &modelCaches, countIn: numbersOfModel(in:)) {
//                        $0.apply(caches: &modelNestedCache, countIn: numbersOfModel(in:))
//                    }
//                case (true, false):
//                    batchUpdate.apply(caches: &modelCaches, countIn: numbersOfModel(in:))
//                case (false, true):
//                    batchUpdate.apply(caches: &modelNestedCache, countIn: numbersOfModel(in:))
//                case (false, false):
//                    batchUpdate.applyData()
//                }
                self.context = context
                if shouldRestDelegate {
                    listView.resetDelegates(toNil: false)
                }
                batchUpdate.apply(by: listView)
            }, animated: animated, completion: { [weak listView] finish in
                listView.map { completion?($0, finish) }
            })
        }
    }
}

extension Delegate {
    func config(context: inout ListCoordinatorContext) {
        context.configSectioned()
        if context.coordinator.needSetupWithListView {
            var storages = [CoordinatorStorage: [IndexPath]]()
            context.coordinator.setupWithListView(offset: .init(), storages: &storages)
            if let storage = context.storage {
                storages[storage, default: []].append(.init())
            }
            for (storage, contexts) in storages {
                storage.contexts[ObjectIdentifier(self)] = (delegateGetter, contexts)
            }
        } else if let storage = context.storage {
            storage.contexts[.init(self)] = (delegateGetter, [.init()])
        }
    }
}

extension Delegate {
    func numberOfItemsInSection(_ section: Int) -> Int {
        context.sections[section]
    }

    func numbersOfSections() -> Int {
        context.sections.count
    }
}

extension Delegate {
    func apply<Input, Output>(
        _ selector: Selector,
        view: AnyObject,
        with input: Input,
        default: @autoclosure () -> Output
    ) -> Output {
        guard valid else { return `default`() }
        return context.apply(selector, view: view, with: input) ?? `default`()
    }

    func apply<Output>(
        _ selector: Selector,
        view: AnyObject,
        default: @autoclosure () -> Output
    ) -> Output {
        guard valid else { return `default`() }
        return context.apply(selector, view: view, with: ()) ?? `default`()
    }

    func apply<Input, Output, Index: ListKit.Index>(
        _ selector: Selector,
        view: AnyObject,
        with input: Input,
        index: Index,
        default: @autoclosure () -> Output
    ) -> Output {
        guard valid else { return `default`() }
        return context.apply(selector, view: view, with: input, index: index, index) ?? `default`()
    }
}
