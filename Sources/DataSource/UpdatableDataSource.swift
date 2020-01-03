//
//  UpdatableDataSource.swift
//  ListKit
//
//  Created by Frain on 2019/12/5.
//

public protocol UpdatableDataSource: DataSource {
    var coordinatorStorage: CoordinatorStorage<SourceBase> { get }
}

public final class CoordinatorStorage<SourceBase: DataSource> {
    var coordinators = [ListCoordinator<SourceBase>]()
    var source: SourceBase.Source!
    var stagingUpdate: [(ListCoordinator<SourceBase>) -> Void]?
    
    public init() { }
    
    deinit {
        
    }
}

public extension UpdatableDataSource {
    var currentSource: SourceBase.Source {
        sourceBase.source(storage: coordinatorStorage)
    }
    
    func performUpdate(animated: Bool = true, completion: ((ListView, Bool) -> Void)? = nil) {
        cancelUpdate()
        coordinatorStorage.source = nil
        coordinatorStorage.coordinators.forEach {
            $0.update(to: sourceBase, animated: animated, completion: completion)
        }
    }
    
    func reloadCurrent(animated: Bool = true, completion: ((ListView, Bool) -> Void)? = nil) {
        cancelUpdate()
        coordinatorStorage.source = nil
        coordinatorStorage.coordinators.forEach {
            $0.reload(to: sourceBase, animated: animated, completion: completion)
        }
    }
    
    func removeCurrent(animated: Bool = true, completion: ((ListView, Bool) -> Void)? = nil) {
        cancelUpdate()
        coordinatorStorage.coordinators.forEach {
            $0.removeCurrent(animated: animated, completion: completion)
        }
    }
      
    func reloadData(animated: Bool = true, completion: ((ListView, Bool) -> Void)? = nil) {
        cancelUpdate()
        coordinatorStorage.source = nil
        coordinatorStorage.coordinators.forEach {
            $0.reloadData(to: sourceBase, animated: animated, completion: completion)
        }
    }
    
    func startUpdate() {
        
    }
    
    func cancelUpdate() {
        
    }
    
    func endUpdate(animated: Bool = true, completion: ((ListView, Bool) -> Void)? = nil) {
        
    }
}

extension DataSource {
    func source(storage: CoordinatorStorage<Self>?) -> Source {
        storage?.source ?? {
            let source = self.source
            storage?.source = source
            return source
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
