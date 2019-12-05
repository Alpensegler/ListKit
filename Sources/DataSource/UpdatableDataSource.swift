//
//  UpdatableDataSource.swift
//  ListKit
//
//  Created by Frain on 2019/12/5.
//

public class CoordinatorStorage<Source: DataSource> {
    var coordinator: ListCoordinator<Source>! {
        didSet {
            coordinator.didUpdateToCoordinator.append { [weak self] (old, new) in
                self?.coordinator = new as? ListCoordinator<Source>
            }
        }
    }
    
    public init() { }
}

public protocol UpdatableDataSource: DataSource {
    var coordinatorStorage: CoordinatorStorage<SourceBase> { get }
}

public extension UpdatableDataSource {
    var listCoordinator: ListCoordinator<SourceBase> {
        coordinatorStorage.coordinator ?? {
            let coordinator = makeListCoordinator()
            coordinatorStorage.coordinator = coordinator
            return coordinator
        }()
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
