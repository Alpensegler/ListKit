//
//  AnyItemSource.swift
//  ListKit
//
//  Created by Frain on 2019/12/11.
//

public struct AnySources: DataSource {
    enum Value {
        case value(Any)
        case getter(() -> Any)
    }
    
    public typealias Item = Any
    public typealias SourceBase = Self
    let coordinatorMaker: (Self) -> ListCoordinator<AnySources>
    let sourceValue: Value
    
    public var source: Any {
        switch sourceValue {
        case let .value(value): return value
        case let .getter(getter): return getter()
        }
    }
    
    public let listDiffer: ListDiffer<AnySources>
    public let listOptions: ListOptions<AnySources>
    public let listUpdate: ListUpdate<SourceBase>.Whole
    
    public var listCoordinator: ListCoordinator<Self> { coordinatorMaker(self) }
    
    public init<Source: DataSource>(_ dataSource: Source) {
        sourceValue = .value(dataSource)
        listDiffer = .init(dataSource.listDiffer) { (($0.source) as! Source).sourceBase }
        listOptions = .init(dataSource.listOptions)
        listUpdate = dataSource.listUpdate.diff.map { .init(diff: .init($0)) } ?? .reload
        coordinatorMaker = { WrapperCoordinator($0, toItem: { $0 }, toOther: { $0 as? Source }) }
    }
    
    public init<Source: DataSource>(
        options: ListOptions<AnySources>,
        _ getter: @escaping () -> Source
    ) {
        let dataSource = getter()
        sourceValue = .getter { getter() }
        listDiffer = .init(dataSource.listDiffer) { (($0.source) as! Source).sourceBase }
        listOptions = options.union(.init(dataSource.listOptions))
        listUpdate = dataSource.listUpdate.diff.map { .init(diff: .init($0)) } ?? .reload
        coordinatorMaker = { WrapperCoordinator($0, toItem: { $0 }, toOther: { $0 as? Source }) }
    }
}

extension AnySources: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String { "AnySources(\(source))" }
    public var debugDescription: String { "AnySources(\(source))" }
}
