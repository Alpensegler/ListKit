//
//  UpdatableDataSource.swift
//  ListKit
//
//  Created by Frain on 2019/12/5.
//

public protocol UpdatableDataSource: DataSource {
    var coordinatorStorage: CoordinatorStorage<SourceBase> { get }
    
    func performUpdate(animated: Bool, completion: ((Bool) -> Void)?)
    func performReloadCurrent(animated: Bool, completion: ((Bool) -> Void)?)
    func performReloadData(_ completion: ((Bool) -> Void)?)
}

public class CoordinatorStorage<Source: DataSource> {
    var coordinator: ListCoordinator<Source>!
    
    public init() { }
}

public extension UpdatableDataSource {
    var listCoordinator: ListCoordinator<SourceBase> {
        coordinatorStorage.coordinator ?? makeListCoordinator()
    }
    
    func performUpdate(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        
    }
    
    func performReloadCurrent(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        
    }
      
    func performReloadData(_ completion: ((Bool) -> Void)? = nil) {
        
    }
}

extension UpdatableDataSource {
    func addToStorage(_ coordinator: ListCoordinator<SourceBase>) -> ListCoordinator<SourceBase> {
        coordinatorStorage.coordinator = coordinator
        return coordinator
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
