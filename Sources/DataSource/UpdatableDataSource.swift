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
        var coordinator: ListCoordinator<SourceBase>!
        var coordinatorUpdate: CoordinatorUpdate<SourceBase>?
        let work = {
            if case let .whole(whole, nil) = update {
                update = .whole(whole, self.sourceBase.source)
            }
            coordinator = self.listCoordinator
            update.source.map { Log.log("from \(currentSource)\n  to \($0)") }
            coordinatorUpdate = coordinator.update(update)
            coordinator.currentCoordinatorUpdate = coordinatorUpdate
        }
        if isMainThread {
            work()
        } else {
            DispatchQueue.main.sync(execute: work)
        }
        let updateAnimated = animated ?? !coordinator.options.contains(.preferNoAnimation)
        var results = [(CoordinatorContext, BatchUpdates)]()
        for context in coordinator.listContexts {
            guard let context = context.context else { return }
            results += context.parentUpdate?(coordinatorUpdate, context.index) ?? []
            if context.listView != nil, let update = coordinatorUpdate?.listUpdates {
                results.append((context, update))
            }
        }
        if results.isEmpty { return }
        let afterWork = {
            for (context, update) in results {
                context.perform(updates: update, animated: updateAnimated, completion: completion)
            }
        }
        if isMainThread {
            afterWork()
        } else {
            DispatchQueue.main.async(execute: afterWork)
        }
    }
    
    func performUpdate(
        animated: Bool? = nil,
        to source: SourceBase.Source,
        completion: ((ListView, Bool) -> Void)? = nil
    ) {
        perform(.whole(listUpdate, source), animated: animated, completion: completion)
    }
    
    func performUpdate(animated: Bool? = nil, completion: ((ListView, Bool) -> Void)? = nil) {
        perform(.whole(listUpdate), animated: animated, completion: completion)
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
