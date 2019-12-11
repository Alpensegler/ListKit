//
//  Source.swift
//  ListKit
//
//  Created by Frain on 2019/10/10.
//

@propertyWrapper
@dynamicMemberLookup
public struct Sources<Source, Item>: UpdatableDataSource {
    let listCoordinatorMaker: (Self) -> ListCoordinator<Self>
    var id: AnyHashable! = nil
    
    public internal(set) var source: Source
    public internal(set) var updater: Updater<Self>
    
    public let coordinatorStorage = CoordinatorStorage<Self>()
    
    public var wrappedValue: Source { source }
    
    public func makeListCoordinator() -> ListCoordinator<Self> {
        listCoordinatorMaker(self)
    }
    
    public subscript<Value>(dynamicMember keyPath: KeyPath<Source, Value>) -> Value {
        source[keyPath: keyPath]
    }
}
