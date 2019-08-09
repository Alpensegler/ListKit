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
}

public struct Snapshot<SubSource, Item> {
    var source: SubSource
    var subSource: [Any]
    var subSnapshots: [Any]
    var isSectioned = true
    
    let subSourceIndices: [[Int]]
    let subSourceOffsets: [IndexPath]
}

extension Snapshot: SnapshotType {
    public func numbersOfItems(in section: Int) -> Int {
        return subSourceIndices[safe: section]?.count ?? 0
    }
    
    public func numbersOfSections() -> Int {
        return isSectioned ? subSourceIndices.count : 0
    }
}
