//
//  Source.swift
//  ListKit
//
//  Created by Frain on 2019/10/10.
//

@propertyWrapper
@dynamicMemberLookup
public struct Sources<Source, Item>: UpdatableDataSource {
    public typealias SourceBase = Self
    let sourceGetter: () -> Source
    let sourceSetter: (Source) -> Void
    let coordinatorMaker: (Self) -> ListCoordinator<Self>
    
    public let differ: Differ<Self>
    public let listUpdate: ListUpdate<Item>
    public let coordinatorStorage = CoordinatorStorage<Self>()
    public var source: Source {
        get { sourceGetter() }
        set {
            sourceSetter(newValue)
            perform(listUpdate, updateData: sourceSetter)
        }
    }
    
    public var wrappedValue: Source {
        get { source }
        set { source = newValue }
    }
    
    public func makeListCoordinator() -> ListCoordinator<Self> { coordinatorMaker(self) }
    public subscript<Value>(dynamicMember keyPath: KeyPath<Source, Value>) -> Value {
        source[keyPath: keyPath]
    }
    
    public subscript<Value>(dynamicMember keyPath: WritableKeyPath<Source, Value>) -> Value {
        get { source[keyPath: keyPath] }
        set { source[keyPath: keyPath] = newValue }
    }
}
