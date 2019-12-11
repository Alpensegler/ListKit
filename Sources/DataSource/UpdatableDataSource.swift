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
    
}
