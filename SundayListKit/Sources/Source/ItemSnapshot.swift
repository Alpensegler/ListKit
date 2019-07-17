//
//  ItemSnapshot.swift
//  SundayListKit
//
//  Created by Frain on 2019/8/1.
//  Copyright © 2019 Frain. All rights reserved.
//

public protocol ItemSnapshot: SnapshotType {
    associatedtype Item
    var item: Item { get }
}

extension Snapshot: ItemSnapshot where SubSource == Item {
    public init(_ source: SubSource) {
        self.source = source
        self.subSource = []
        self.subSnapshots = []
        self.isSectioned = false
        self.subSourceIndices = []
        self.subSourceOffsets = []
    }
    
    public var item: SubSource { return source }
}

public extension Source where SourceSnapshot == Snapshot<SubSource, Item>, SubSource == Item, Item == SourceSnapshot.Item, SourceSnapshot.SubSource == SourceSnapshot.Item {
    func createSnapshot(with source: SubSource) -> SourceSnapshot { return .init(source) }
    func item(for snapshot: SourceSnapshot, at indexPath: IndexPath) -> Item {
        return snapshot.item
    }
}

public extension Source where SourceSnapshot: ItemSnapshot, Item == SourceSnapshot.Item, Item: Equatable {
    func update(context: UpdateContext<SourceSnapshot>) {
        context.diffUpdate()
    }
}

public extension UpdateContext where Snapshot: ItemSnapshot, Snapshot.Item: Equatable {
    func diffUpdate() {
        if rawSnapshot.item == snapshot.item { return }
        reloadCurrent()
    }
}

public extension UpdateContext where Snapshot: ItemSnapshot, Snapshot.Item: Identifiable {
    func diffUpdate() {
        if rawSnapshot.item.id == snapshot.item.id { return }
        reloadCurrent()
    }
}

public extension UpdateContext where Snapshot: ItemSnapshot, Snapshot.Item: Diffable {
    func diffUpdate() {
        if rawSnapshot.item == snapshot.item { return }
        reloadCurrent()
    }
}
