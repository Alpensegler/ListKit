//
//  UpdatableDataSource.swift
//  ListKit
//
//  Created by Frain on 2019/12/5.
//

import Foundation

public protocol UpdatableDataSource: DataSource {
    var coordinatorStorage: CoordinatorStorage<SourceBase> { get }
}

public final class CoordinatorStorage<SourceBase: DataSource>
where SourceBase.SourceBase == SourceBase {
    var coordinator: ListCoordinator<SourceBase>?
    
    public init() { }
}

public extension UpdatableDataSource {
    var currentSource: SourceBase.Source { listCoordinator.source }
    
    func perform(
        _ update: ListUpdate<SourceBase>,
        animated: Bool? = nil,
        completion: ((ListView, Bool) -> Void)? = nil
    ) {
        if update.isEmpty { return }
        let isMainThread = Thread.isMainThread
        var update = update
        var coordinator: ListCoordinator<SourceBase>!, options: ListOptions<SourceBase>!
        let work = {
            coordinator = self.listCoordinator
            options = self.listOptions
            Log.log("----start-update: \(update.updateType)----")
            if update.needSource, update.source == nil {
                update.source = self.sourceBase.source
                Log.log("from \(self.currentSource)")
                Log.log("to   \(update.source!)")
            }
        }
        isMainThread ? work() : DispatchQueue.main.sync(execute: work)
        let coordinatorUpdate = coordinator.update(update)
        coordinator.currentCoordinatorUpdate = coordinatorUpdate
        let contextAndUpdates = coordinator.contextAndUpdates(update: coordinatorUpdate)
        let results = contextAndUpdates.compactMap { arg in
            arg.1.listUpdates.map { (arg.0, arg.1, $0) }
        }
        if results.isEmpty { return }
        let afterWork = {
            let updateAnimated = animated ?? !options.contains(.preferNoAnimation)
            for (context, coordinatorUpdate, update) in results {
                coordinatorUpdate.finalChange?()
                context.perform(updates: update, animated: updateAnimated, completion: completion)
            }
        }
        isMainThread ? afterWork() : DispatchQueue.main.sync(execute: afterWork)
    }
    
    func performUpdate(
        animated: Bool? = nil,
        to source: SourceBase.Source,
        completion: ((ListView, Bool) -> Void)? = nil
    ) {
        perform(
            .init(updateType: .whole(listUpdate), source: source),
            animated: animated,
            completion: completion
        )
    }
    
    func performUpdate(animated: Bool? = nil, completion: ((ListView, Bool) -> Void)? = nil) {
        perform(.init(updateType: .whole(listUpdate)), animated: animated, completion: completion)
    }
    
    func getCache<List: ListView>(for listView: List, at indexPath: IndexPath) -> Any? {
        let c = listCoordinator.listContexts.first { $0.context?.listView == listView }?.context
        guard let context = c, context._itemCaches != nil else { return nil }
        return context.itemCaches[indexPath.section][indexPath.item]
    }
    
    func currentItem(at indexPath: IndexPath) -> Item {
        listCoordinator.item(at: indexPath)
    }
}

extension UpdatableDataSource where SourceBase == Self {
    func coordinator(
        with initialize: @autoclosure () -> ListCoordinator<SourceBase>
    ) -> ListCoordinator<SourceBase> {
        coordinatorStorage.coordinator ?? {
            let coordinator = initialize()
            coordinatorStorage.coordinator = coordinator
            coordinator.storage = coordinatorStorage
            return coordinator
        }()
    }
}

#if canImport(ObjectiveC)
import ObjectiveC.runtime

private var coordinatorStorageKey: Void?

public extension UpdatableDataSource where Self: AnyObject {
    var coordinatorStorage: CoordinatorStorage<SourceBase> {
        get { Associator.getValue(key: &coordinatorStorageKey, from: self, initialValue: .init()) }
        set { Associator.set(value: newValue, key: &coordinatorStorageKey, to: self) }
    }
}

#endif
