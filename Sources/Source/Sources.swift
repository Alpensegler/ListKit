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
    
    public var source: Source {
        get { coordinatorStorage.coordinator?.source ?? sourceGetter() }
        nonmutating set {
            sourceSetter(newValue)
            perform(listUpdate, updateData: sourceSetter)
        }
    }
    
    public let listUpdate: ListUpdate<Item>
    public var listOptions: ListOptions<Self>
    
    public var listCoordinator: ListCoordinator<Self> { coordinator(with: coordinatorMaker(self)) }
    
    public let coordinatorStorage = CoordinatorStorage<Self>()
    
    public var wrappedValue: Source {
        get { source }
        nonmutating set { source = newValue }
    }
    
    public subscript<Value>(dynamicMember keyPath: KeyPath<Source, Value>) -> Value {
        source[keyPath: keyPath]
    }
    
    public subscript<Value>(dynamicMember keyPath: WritableKeyPath<Source, Value>) -> Value {
        get { source[keyPath: keyPath] }
        nonmutating set { source[keyPath: keyPath] = newValue }
    }
}

public extension Sources {
    struct Options: ListKit.Options {
        public typealias SourceBase = Sources<Source, Item>
        
        public var rawValue: Int8
        public init(rawValue: Int8) { self.rawValue = rawValue }
    }
    
}
