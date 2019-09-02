//
//  ItemSnapshot.swift
//  SundayListKit
//
//  Created by Frain on 2019/8/1.
//  Copyright © 2019 Frain. All rights reserved.
//

extension Snapshot where SubSource == Item {
    public init(_ source: SubSource) {
        self.isSectioned = false
        self.subSource = [source]
        self.subSnapshots = []
        self.subSourceIndices = [.cell([0])]
        self.subSourceOffsets = [.default]
    }
    
    public var item: SubSource { return subSource[0] as! SubSource }
}

public extension Source where SubSource == Item {
    func createSnapshot(with source: SubSource) -> Snapshot<SubSource, Item> { return .init(source) }
    func item(for snapshot: Snapshot<SubSource, Item>, at indexPath: IndexPath) -> Item {
        return snapshot.item
    }
}

public extension Source where SubSource == Item, Item: Equatable {
    func update(context: UpdateContext<SubSource, Item>) {
        context.diffUpdate()
    }
}

public extension UpdateContext where SubSource == Item, Item: Equatable {
    func diffUpdate() {
        if rawSnapshot.item == snapshot.item { return }
        reloadCurrent()
    }
}

public extension UpdateContext where SubSource == Item, Item: Identifiable {
    func diffUpdate() {
        if rawSnapshot.item.id == snapshot.item.id { return }
        reloadCurrent()
    }
}

public extension UpdateContext where SubSource == Item, Item: Diffable {
    func diffUpdate() {
        if rawSnapshot.item == snapshot.item { return }
        reloadCurrent()
    }
}
