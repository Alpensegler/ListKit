//
//  AnySource.swift
//  ListKit
//
//  Created by Frain on 2019/12/11.
//

// swiftlint:disable comment_spacing

//public struct AnySources: DataSource {
//    public typealias Model = Any
//    public typealias SourceBase = Self
//    let coordinatorMaker: (Self) -> ListCoordinator<AnySources>
//
//    public let source: Any
//    public let listDiffer: ListDiffer<AnySources>
//    public let listOptions: ListOptions
//    public let listUpdate: ListUpdate<SourceBase>.Whole
//
//    public var listCoordinator: ListCoordinator<Self> { coordinatorMaker(self) }
//
//    public init<Source: DataSource>(_ dataSource: Source, options: ListOptions = .init()) {
//        source = dataSource
//        listDiffer = .init(dataSource.listDiffer) { (($0.source) as! Source).sourceBase }
//        listOptions = dataSource.listOptions.union(options)
//        listUpdate = .init(way: .subupdate)
//        coordinatorMaker = { WrapperCoordinator($0, toModel: { $0 }, toOther: { $0 as? Source }) }
//    }
//}
//
//extension AnySources: CustomStringConvertible, CustomDebugStringConvertible {
//    public var description: String { "AnySources(\(source))" }
//    public var debugDescription: String { "AnySources(\(source))" }
//}
//
//extension AnySources {
//    init(anySources: AnySources, options: ListOptions) {
//        self.source = anySources.source
//        self.listDiffer = anySources.listDiffer
//        self.listOptions = anySources.listOptions.union(options)
//        self.listUpdate = anySources.listUpdate
//        self.coordinatorMaker = anySources.coordinatorMaker
//    }
//}
