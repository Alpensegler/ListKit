//
//  Source.swift
//  SundayListKit
//
//  Created by Frain on 2019/4/8.
//  Copyright © 2019 Frain. All rights reserved.
//

public protocol Source {
    associatedtype Item
    associatedtype SubSource = [Item]
    associatedtype SourceSnapshot: SnapshotType = Snapshot<SubSource, Item>
    
    var source: SubSource { get }
    func createSnapshot(with source: SubSource) -> SourceSnapshot
    
    func item(for snapshot: SourceSnapshot, at indexPath: IndexPath) -> Item
    
    func update(context: UpdateContext<SourceSnapshot>)
    func eraseToSources() -> Sources<SubSource, Item, SourceSnapshot, Never>
}

public extension Source where SubSource: Collection {
    typealias Element = SubSource.Element
}

public protocol SnapshotType {
    func numbersOfSections() -> Int
    func numbersOfItems(in section: Int) -> Int
    var isSectioned: Bool { get }
}

public protocol CollectionSnapshotType: SnapshotType {
    associatedtype Element
    var elements: [Element] { get }
}

enum SnapshotIndices {
    case section(Int, Int)
    case cell([Int])
    
    var count: Int {
        switch self {
        case let .section(_, count):
            return count
        case let .cell(cells):
            return cells.count
        }
    }
}

protocol SubSourceContainSnapshot: SnapshotType {
    var subSource: [Any] { get }
    var subSnapshots: [SnapshotType] { get }
    
    var subSourceIndices: [SnapshotIndices] { get }
    var subSourceOffsets: [IndexPath] { get }
    
    mutating func updateSubSource(with snapshot: SnapshotType?, at index: Int)
}

public struct Snapshot<SubSource, Item>: CustomStringConvertible {
    public let isSectioned: Bool
    var source: SubSource
    var subSource: [Any]
    var subSnapshots: [SnapshotType]
    
    var subSourceIndices: [SnapshotIndices] = []
    var subSourceOffsets: [IndexPath] = []
    
    public var description: String {
        if subSnapshots.isEmpty {
            return "\(source)"
        } else {
            return "\(source), \(subSnapshots), \(subSourceIndices)"
        }
    }
}

extension Snapshot: SnapshotType {
    public func numbersOfItems(in section: Int) -> Int {
        return subSourceIndices[safe: section]?.count ?? 0
    }
    
    public func numbersOfSections() -> Int {
        return isSectioned ? subSourceIndices.count : 0
    }
}

extension Snapshot: CollectionSnapshotType where SubSource: Collection {
    public typealias Element = SubSource.Element
    public var elements: [Element] {
        return subSource as! [Element]
    }
}
