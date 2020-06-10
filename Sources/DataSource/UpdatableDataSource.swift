//
//  UpdatableDataSource.swift
//  ListKit
//
//  Created by Frain on 2019/12/5.
//

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
        _ update: ListUpdate<Item>,
        animated: Bool = true,
        completion: ((ListView, Bool) -> Void)? = nil,
        updateData: ((SourceBase.Source) -> Void)? = nil
    ) {
        listCoordinator.perform(update, to: sourceBase.source, animated, completion, updateData)
    }
    
    func performUpdate(
        animated: Bool = true,
        completion: ((ListView, Bool) -> Void)? = nil,
        updateData: ((SourceBase.Source) -> Void)? = nil
    ) {
        perform(listUpdate, animated: animated, completion: completion, updateData: updateData)
    }
    
    func removeCurrent(animated: Bool = true, completion: ((ListView, Bool) -> Void)? = nil) {
        listCoordinator.removeCurrent(animated: animated, completion: completion)
    }
    
    func startUpdate() {
        listCoordinator.startUpdate()
    }
    
    func endUpdate(animated: Bool = true, completion: ((ListView, Bool) -> Void)? = nil) {
        listCoordinator.endUpdate(animated: animated, completion: completion)
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
