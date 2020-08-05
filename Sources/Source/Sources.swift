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
    
    public let listUpdate: ListUpdate<SourceBase>.Whole
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

public extension Sources {
    struct Options: ListKit.Options {
        public typealias SourceBase = Sources<Source, Item>
        
        public var rawValue: Int8
        public init(rawValue: Int8) { self.rawValue = rawValue }
    }
    
}

public typealias ItemsSources<Item> = Sources<[Int], Int>
public typealias SectionsSources<Item> = Sources<[[Int]], Int>
public typealias SourcesSources<Source: DataSource> = Sources<[Source], Source.Item>
