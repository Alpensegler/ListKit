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
    var isObjectAssciated = false
    weak var object: AnyObject?
    
    public init() { }
    
    init(_ object: AnyObject) {
        self.object = object
        self.isObjectAssciated = true
    }
    
    deinit {
        coordinator?.listContexts.forEach {
            $0.context?.listView?.resetDelegates()
        }
    }
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
        var coordinator: ListCoordinator<SourceBase>!, options: ListOptions!
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
        let coordinatorUpdate = coordinator.update(update: update, options: options)
        let contextAndUpdates = coordinator.contextAndUpdates(update: coordinatorUpdate)
        let results = contextAndUpdates?.compactMap { arg in
            arg.1.listUpdates.map { (arg.0, arg.1, $0) }
        }
        let afterWork: () -> Void = {
            guard let results = results else { return coordinatorUpdate.finalChange(true)() }
            for (context, coordinatorUpdate, update) in results {
                let updateAnimated = animated ?? !coordinatorUpdate.options.target.preferNoAnimation
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
}

public extension UpdatableDataSource {
    func currentItem(at indexPath: IndexPath) -> Item {
        listCoordinator.item(at: indexPath)
    }
    
    func currentNumbersOfSections() -> Int {
        listCoordinator.numbersOfSections()
    }
    
    func currentNumbersOfItem(in section: Int) -> Int {
        listCoordinator.numbersOfItems(in: section)
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

extension UpdatableDataSource {
    func _itemContext<List: ListView>(
        for listView: List,
        at indexPath: IndexPath
    ) -> [ListItemContext<List>] {
        var results = [ListItemContext<List>]()
        for context in listCoordinator.listContexts {
            guard let context = context.context else { continue }
            if context.listView === listView {
                results.append(.init(
                    listView: listView,
                    index: indexPath,
                    offset: .zero,
                    context: context,
                    root: context
                ))
            }
            
            for (offset, root) in context.contextAtIndex?(context.index, .zero, listView) ?? [] {
                results.append(.init(
                    listView: listView,
                    index: indexPath.offseted(offset),
                    offset: offset,
                    context: context,
                    root: root
                ))
            }
        }
        return results
    }
}

#if canImport(ObjectiveC)
import ObjectiveC.runtime

private var storageKey: Void?

public extension UpdatableDataSource where Self: AnyObject {
    var coordinatorStorage: CoordinatorStorage<SourceBase> {
        get { Associator.getValue(key: &storageKey, from: self, initialValue: .init(self)) }
        set { Associator.set(value: newValue, key: &storageKey, to: self) }
    }
}

#endif
