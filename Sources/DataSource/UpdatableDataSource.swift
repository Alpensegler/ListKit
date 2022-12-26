//
//  UpdatableDataSource.swift
//  ListKit
//
//  Created by Frain on 2019/12/5.
//

import Foundation

public protocol UpdatableDataSource: DataSource {
    var coordinatorStorage: CoordinatorStorage<Model> { get }
}

public final class CoordinatorStorage<Model> {
    var coordinator: ListCoordinator<Model>?
    var isObjectAssciated = false
    weak var object: AnyObject?

    public init() { }

    init(_ object: AnyObject) {
        self.object = object
        self.isObjectAssciated = true
    }

    deinit {
        coordinator?.listContexts.forEach {
            $0.context?.listView?.resetDelegates(toNil: true)
        }
    }
}

public extension UpdatableDataSource {
    var listCoordinator: ListCoordinator<Model> {
        coordinatorStorage.coordinator ?? {
            let coordinator = source.listCoordinator
            coordinatorStorage.coordinator = coordinator
            coordinator.storage = coordinatorStorage
            return coordinator
        }()
    }

    var listCoordinatorContext: ListCoordinatorContext<Model> {
        .init(listCoordinator)
    }

//    var currentSource: SourceBase.Source { listCoordinator.source }

    private func _perform(
//        _ update: ListUpdate<SourceBase>,
        animated: Bool? = nil,
        completion: ((ListView, Bool) -> Void)? = nil
    ) {
//        if update.isEmpty { return }
        guard let currentCoordinator = coordinatorStorage.coordinator else {
            return
        }
        let isMainThread = Thread.isMainThread
//        var update = update
        var coordinator: ListCoordinator<Model>!
        let work = {
            coordinator = source.listCoordinator
//            Log.log("----start-update: \(update.updateType)----")
//            if update.needSource, update.source == nil {
//                update.source = self.sourceBase.source
//                Log.log("from \(self.currentSource)")
//                Log.log("to   \(update.source!)")
//            }
        }
        _ = isMainThread ? work() : DispatchQueue.main.sync(execute: work)
        let coordinatorUpdate = coordinator.update(from: currentCoordinator)
        let contextAndUpdates = currentCoordinator.contextAndUpdates(update: coordinatorUpdate)
        let results = contextAndUpdates?.map { arg in (arg.0, arg.1, arg.1.listUpdates) }
        let afterWork: () -> Void = {
            guard let results = results else { return coordinatorUpdate.finalChange(true)() }
            for (context, coordinatorUpdate, update) in results {
                let updateAnimated = animated ?? !coordinatorUpdate.options.target.preferNoAnimation
                context.perform(to: coordinator, updates: update, animated: updateAnimated, completion: completion)
            }
            coordinatorStorage.coordinator = coordinator
        }
        _ = isMainThread ? afterWork() : DispatchQueue.main.sync(execute: afterWork)
    }

//    func performUpdate(
//        animated: Bool? = nil,
//        to source: SourceBase.Source,
//        completion: ((ListView, Bool) -> Void)? = nil
//    ) {
//        perform(
//            .init(updateType: .whole(listUpdate), source: source),
//            animated: animated,
//            completion: completion
//        )
//    }

    func performUpdate(animated: Bool? = nil, completion: ((ListView, Bool) -> Void)? = nil) {
        _perform(animated: animated, completion: completion)
    }
}

//public extension UpdatableDataSource {
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
//extension UpdatableDataSource {
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
//extension UpdatableDataSource where Self: ListAdapter {
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
//}

#if canImport(ObjectiveC)
import ObjectiveC.runtime

private var storageKey: Void?

public extension UpdatableDataSource where Self: AnyObject {
    var coordinatorStorage: CoordinatorStorage<Model> {
        get { Associator.getValue(key: &storageKey, from: self, initialValue: .init(self)) }
        set { Associator.set(value: newValue, key: &storageKey, to: self) }
    }
}

#endif
