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
    let sourceValue: Source
    let coordinatorMaker: (Self) -> ListCoordinator<Self>
    
    public var source: Source {
        get { coordinatorStorage.coordinator?.source ?? sourceValue }
        nonmutating set { performUpdate(to: newValue) }
    }
    
    public let listDiffer: ListDiffer<Self>
    public let listUpdate: ListUpdate<Self>.Whole
    public var listOptions: ListOptions<Self>
    
    public var listCoordinator: ListCoordinator<Self> { coordinator(with: coordinatorMaker(self)) }
    
    public let coordinatorStorage = CoordinatorStorage<Self>()
    
    public var wrappedValue: Source {
        get { source }
        nonmutating set { source = newValue }
    }
    
    public var projectedValue: Sources<Source, Item> {
        get { self }
        set { self = newValue }
    }
    
    public subscript<Value>(dynamicMember keyPath: KeyPath<Source, Value>) -> Value {
        source[keyPath: keyPath]
    }
    
    public subscript<Value>(dynamicMember keyPath: WritableKeyPath<Source, Value>) -> Value {
        get { source[keyPath: keyPath] }
        nonmutating set { source[keyPath: keyPath] = newValue }
    }
}

extension Sources: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String { "Sources(\(source))" }
    public var debugDescription: String { "Sources(\(source))" }
}

public typealias ItemSources<Item> = Sources<Item, Item>
public typealias ItemsSources<Item> = Sources<[Item], Item>
public typealias SectionsSources<Item> = Sources<[[Item]], Item>
public typealias SourceSources<Source: DataSource> = Sources<Source, Source.Item>
public typealias SourcesSources<Source: DataSource> = Sources<[Source], Source.Item>
