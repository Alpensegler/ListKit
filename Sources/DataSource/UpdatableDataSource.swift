//
//  UpdatableDataSource.swift
//  ListKit
//
//  Created by Frain on 2019/12/5.
//

public protocol UpdatableDataSource: DataSource {
    var coordinatorStorage: CoordinatorStorage<SourceBase> { get }
}

public final class CoordinatorStorage<SourceBase: DataSource> where SourceBase.SourceBase == SourceBase {
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
    
    func perform(
        _ update: ListUpdate<Item>,
        animated: Bool = true,
        completion: ((ListView, Bool) -> Void)? = nil,
        updateData: ((SourceBase.Source) -> Void)? = nil
    ) {
        let source = sourceBase.source
        coordinatorStorage.source = nil
        coordinatorStorage.coordinators.forEach {
            $0.perform(update, to: source, animated, completion, updateData)
        }
    }
    
    func performUpdate(
        animated: Bool = true,
        completion: ((ListView, Bool) -> Void)? = nil,
        updateData: ((SourceBase.Source) -> Void)? = nil
    ) {
        perform(listUpdate, animated: animated, completion: completion, updateData: updateData)
    }
    
    func removeCurrent(animated: Bool = true, completion: ((ListView, Bool) -> Void)? = nil) {
        cancelUpdate()
        coordinatorStorage.coordinators.forEach {
            $0.removeCurrent(animated: animated, completion: completion)
        }
    }
    
    func startUpdate() {
        
    }
    
    func cancelUpdate() {
        
    }
    
    func endUpdate(animated: Bool = true, completion: ((ListView, Bool) -> Void)? = nil) {
        
    }
}

extension DataSource where SourceBase == Self {
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
