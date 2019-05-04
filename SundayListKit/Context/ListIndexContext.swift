//
//  listContext.swift
//  SundayListKit
//
//  Created by Frain on 2019/4/16.
//  Copyright © 2019 Frain. All rights reserved.
//

public struct ListIndexContext<List: ListView, Value: Source>: Updater {
    public typealias Snapshot = Value.Snapshot
    public let indexPath: IndexPath
    public let listView: List
    public let snapshot: Snapshot
    let offset: IndexPath
    let listUpdater: ListUpdater<Value>
    var listIndexPath: IndexPath {
        return IndexPath(item: offset.item + indexPath.item, section: offset.section + indexPath.section)
    }
    
    public var updaters: [ListUpdater<Value>] { return [listUpdater] }
    
    public var section: Int {
        return indexPath.section
    }
    
    public var item: Int {
        return indexPath.row
    }
    
    public var index: Int {
        return item
    }
    
    init(listView: List, snapshot: Snapshot, indexPath: IndexPath) {
        self.listView = listView
        self.indexPath = indexPath
        self.offset = .default
        self.snapshot = snapshot
        self.listUpdater = ListUpdater(listView: listView)
    }
    
    init(listView: List, snapshot: Snapshot, indexPath: IndexPath, offset: IndexPath) {
        self.listView = listView
        self.indexPath = indexPath
        self.offset = offset
        self.snapshot = snapshot
        self.listUpdater = ListUpdater(listView: listView, offset: offset, sectionCount: snapshot.numbersOfSections(), cellCount: snapshot.numbersOfItems(in: 0))
    }
}

public extension ListIndexContext where Value: CollectionSource {
    func element() -> Value.Element {
        return snapshot.element(for: indexPath)
    }
}

public extension ListIndexContext where Value: CollectionSource, Value.Element: Source {
    func elementItem() -> Value.Element.Item {
        let element = self.element()
        return element.item(for: subContext)
    }
    
    var subContext: ListIndexContext<List, Value.Element> {
        let snapshot = self.snapshot.snapshot(for: indexPath)
        let offset = self.snapshot.elementOffset(for: indexPath)
        let indexPath = IndexPath(item: listIndexPath.item - offset.item, section: listIndexPath.section - offset.section)
        return ListIndexContext<List, Value.Element>(listView: listView, snapshot: snapshot, indexPath: indexPath, offset: offset)
    }
}

public extension ListIndexContext {
    func dequeueReusableCell<CustomCell: UIView>(
        withCellClass cellClass: CustomCell.Type,
        identifier: String = "",
        configuration: (CustomCell) -> Void = { _ in }
    ) -> List.Cell {
        return listView.dequeueReusableCell(
            withCellClass: cellClass,
            identifier: identifier,
            indexPath: listIndexPath,
            configuration: configuration
        )
    }
    
    func dequeueReusableCell<CustomCell: UIView>(
        withCellClass cellClass: CustomCell.Type,
        withNibName nibName: String,
        bundle: Bundle? = nil,
        configuration: (CustomCell) -> Void = { _ in }
      ) -> List.Cell {
        return listView.dequeueReusableCell(
            withCellClass: cellClass,
            withNibName: nibName,
            bundle: bundle,
            indexPath: listIndexPath,
            configuration: configuration
        )
    }
    
    func dequeueReusableSupplementaryView<CustomSupplementaryView: UIView>(
        type: SupplementaryViewType,
        withSupplementaryClass supplementaryClass: CustomSupplementaryView.Type,
        identifier: String = "",
        configuration: (CustomSupplementaryView) -> Void = { _ in }
    ) -> List.SupplementaryView {
        return listView.dequeueReusableSupplementaryView(
            type: type,
            withSupplementaryClass: supplementaryClass,
            identifier: identifier,
            indexPath: listIndexPath,
            configuration: configuration
        )
    }
    
    func dequeueReusableSupplementaryView<CustomSupplementaryView: UIView>(
        type: SupplementaryViewType,
        withSupplementaryClass cellClass: CustomSupplementaryView.Type,
        nibName: String,
        bundle: Bundle? = nil,
        configuration: (CustomSupplementaryView) -> Void = { _ in }
    ) -> List.SupplementaryView {
        return listView.dequeueReusableSupplementaryView(
            type: type,
            withSupplementaryClass: cellClass,
            nibName: nibName,
            bundle: bundle,
            indexPath: listIndexPath,
            configuration: configuration
        )
    }
}
