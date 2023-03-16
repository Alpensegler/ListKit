//
//  UpdatableListAdapter.swift
//  ListKit
//
//  Created by Frain on 2019/12/5.
//

import Foundation

public protocol UpdatableListAdapter: ListAdapter {
    var coordinatorStorage: CoordinatorStorage { get }
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

public extension UpdatableListAdapter where List == DataSource {
    var listCoordinatorContext: ListCoordinatorContext {
        listCoordinatorContext(from: list)
    }

//    var currentSource: SourceBase.Source { listCoordinator.source }

    private func _perform(
        reload: Bool,
        animated: Bool,
        completion: ((ListView, Bool) -> Void)? = nil
    ) {
//        if update.isEmpty { return }
        guard let currentContext = coordinatorStorage.context else {
            return
        }
        let isMainThread = Thread.isMainThread
//        var update = update
        var context: ListCoordinatorContext!
        let work = {
            context = self.list.listCoordinatorContext
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
            guard !coordinatorStorage.contexts.isEmpty else { return }
            for (delegateGetter, positions) in coordinatorStorage.contexts.values {
                delegateGetter()?.perform(update: update, animated: animated, to: context, at: positions, completion: completion)
            }
        }
        _ = isMainThread ? afterWork() : DispatchQueue.main.sync(execute: afterWork)
    }

    func performReload(
        animated: Bool = true,
        completion: ((ListView, Bool) -> Void)? = nil
    ) {
        _perform(reload: true, animated: animated, completion: completion)
    }

    func performUpdate(animated: Bool = true, completion: ((ListView, Bool) -> Void)? = nil) {
        _perform(reload: false, animated: animated, completion: completion)
    }
}

//public extension UpdatableListAdapter {
//    func currentModel(at indexPath: IndexPath) -> Model {
//        listCoordinator.model(at: indexPath)
//    }
//
//    func currentNumbersOfSections() -> Int {
//        listCoordinator.numbersOfSections()
//    }
//
//    func currentNumbersOfModel(in section: Int) -> Int {
//        listCoordinator.numbersOfModel(in: section)
//    }
//}
//

extension UpdatableListAdapter {
    func listCoordinatorContext(from list: DataSource) -> ListCoordinatorContext {
        coordinatorStorage.context ?? {
            var context = list.listCoordinatorContext
            context.storage = coordinatorStorage
            coordinatorStorage.context = context
            return context
        }()
    }
}
//    func coordinator(
//        with initialize: @autoclosure () -> ListCoordinator<SourceBase>
//    ) -> ListCoordinator<SourceBase> {
//        coordinatorStorage.coordinator ?? {
//            let coordinator = initialize()
//            coordinatorStorage.coordinator = coordinator
//            coordinator.storage = coordinatorStorage
//            return coordinator
//        }()
//    }
//}
//
//extension UpdatableListAdapter where Self: ListAdapter {
//    func _modelContext(
//        for listView: View,
//        at indexPath: IndexPath
//    ) -> [ListModelContext] {
//        var results = [ListModelContext]()
//        for context in listCoordinator.listContexts {
//            guard let context = context.context else { continue }
//            if context.listView === listView {
//                results.append(.init(
//                    listView: listView,
//                    index: indexPath,
//                    offset: .zero,
//                    context: context,
//                    root: context
//                ))
//            }
//
//            for (offset, root) in context.contextAtIndex?(context.index, .zero, listView) ?? [] {
//                results.append(.init(
//                    listView: listView,
//                    index: indexPath.offseted(offset),
//                    offset: offset,
//                    context: context,
//                    root: root
//                ))
//            }
//        }
//        return results
//    }

#if canImport(ObjectiveC)
import ObjectiveC.runtime

private var storageKey: Void?

public extension UpdatableListAdapter where Self: AnyObject {
    var coordinatorStorage: CoordinatorStorage {
        get { Associator.getValue(key: &storageKey, from: self, initialValue: .init(self)) }
        set { Associator.set(value: newValue, key: &storageKey, to: self) }
    }
}

#endif
