//
//  UpdatableDataSource.swift
//  ListKit
//
//  Created by Frain on 2019/12/5.
//

public class CoordinatorStorage<Source: DataSource> {
    var coordinator: SourceListCoordinator<Source>!
    
    public init() { }
}

public protocol UpdatableDataSource: DataSource {
    var coordinatorStorage: CoordinatorStorage<SourceBase> { get }
}

public extension UpdatableDataSource {
    var listCoordinator: ListCoordinator {
        coordinatorStorage.coordinator ?? {
            let coordinator = makeListCoordinator() as! SourceListCoordinator<SourceBase>
            coordinatorStorage.coordinator = coordinator
            return coordinator
        }()
    }
    
    func performReloadCurrent(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        
    }
      
    func performReloadData(_ completion: ((Bool) -> Void)? = nil) {
        
    }
}

extension UpdatableDataSource {
    
}
