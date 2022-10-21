//
//  Source.swift
//  ListKit
//
//  Created by Frain on 2019/10/10.
//

// swiftlint:disable comment_spacing

//@propertyWrapper
//@dynamicMemberLookup
//public struct Sources<Source, Model>: UpdatableDataSource {
//    enum Value {
//        case value(Source)
//        case getter(() -> Source)
//    }
//
//    public typealias SourceBase = Self
//    let sourceValue: Value
//    let coordinatorMaker: (Self) -> ListCoordinator<Self>
//
//    public var source: Source {
//        get {
//            switch sourceValue {
//            case let .value(value): return coordinatorStorage.coordinator?.source ?? value
//            case let .getter(getter): return getter()
//            }
//        }
//        nonmutating set {
//            performUpdate(to: newValue)
//        }
//    }
//
//    public let listDiffer: ListDiffer<Self>
//    public let listUpdate: ListUpdate<Self>.Whole
//    public var listOptions: ListOptions
//
//    public var listCoordinator: ListCoordinator<Self> { coordinator(with: coordinatorMaker(self)) }
//
//    public let coordinatorStorage = CoordinatorStorage<Self>()
//
//    public var wrappedValue: Source {
//        get { source }
//        nonmutating set { source = newValue }
//    }
//
//    public var projectedValue: Sources<Source, Model> {
//        get { self }
//        set { self = newValue }
//    }
//
//    public subscript<Value>(dynamicMember keyPath: KeyPath<Source, Value>) -> Value {
//        source[keyPath: keyPath]
//    }
//
//    public subscript<Value>(dynamicMember keyPath: WritableKeyPath<Source, Value>) -> Value {
//        get { source[keyPath: keyPath] }
//        nonmutating set { source[keyPath: keyPath] = newValue }
//    }
//}
//
//extension Sources: CustomStringConvertible, CustomDebugStringConvertible {
//    public var description: String { "Sources(\(source))" }
//    public var debugDescription: String { "Sources(\(source))" }
//}
//
//public typealias ModelSources<Model> = Sources<Model, Model>
//public typealias ModelsSources<Model> = Sources<[Model], Model>
//public typealias SectionsSources<Model> = Sources<[[Model]], Model>
//public typealias SourceSources<Source: DataSource> = Sources<Source, Source.Model>
//public typealias SourcesSources<Source: DataSource> = Sources<[Source], Source.Model>
