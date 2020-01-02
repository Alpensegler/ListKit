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

public class CoordinatorStorage<SourceBase: DataSource> {
    var coordinators = [ListCoordinator<SourceBase>]()
    var coordinator: ListCoordinator<SourceBase>!
    var source: SourceBase.Source!
    
    public init() { }
    
    deinit {
        
    }
}

public extension UpdatableDataSource {
    var currentSource: SourceBase.Source {
        coordinatorStorage.source ?? {
            let source = self.sourceBase.source
            coordinatorStorage.source = source
            return source
        }()
    }
    
    func performUpdate(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        
    }
    
    func performReloadCurrent(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        
    }
      
    func performReloadData(_ completion: ((Bool) -> Void)? = nil) {
        
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
