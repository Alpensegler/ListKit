//
//  Context.swift
//  SundayListKit
//
//  Created by Frain on 2019/7/26.
//  Copyright © 2019 Frain. All rights reserved.
//

public protocol Context {
    associatedtype List: ListView
    associatedtype SubSource
    associatedtype Item
    
    var listView: List { get }
    var snapshot: Snapshot<SubSource, Item> { get }
    var indexPath: IndexPath { get }
    var offset: IndexPath { get }
}

public extension Context {
    var cell: List.Cell? {
        return listView.cellForItem(at: listIndexPath)
    }
    
    var item: Int {
        return indexPath.item
    }
    
    var section: Int {
        return indexPath.section
    }
    
    var listIndexPath: IndexPath {
        return indexPath.addingOffset(offset)
    }
    
    func selectItem(animated: Bool, scrollPosition: List.ScrollPosition) {
        listView.selectItem(at: listIndexPath, animated: animated, scrollPosition: scrollPosition)
    }
    
    func deselectItem(animated: Bool) {
        listView.deselectItem(at: listIndexPath, animated: animated)
    }
}

public extension Context where SubSource: Collection, SubSource.Element: Source, Item == SubSource.Element.Item {
    var elementsItem: SubSource.Element.Item {
        return snapshot.item(at: indexPath)
    }
    
    var element: SubSource.Element {
        let index = snapshot.index(of: indexPath)
        return snapshot.elements[index]
    }
}

public struct CollectionContext<SubSource, Item>: Context {
    public typealias List = UICollectionView
    
    public let snapshot: Snapshot<SubSource, Item>
    public let indexPath: IndexPath
    public let offset: IndexPath
    public let listView: List
    
    init(listView: List, indexPath: IndexPath, offset: IndexPath = .default, snapshot: Snapshot<SubSource, Item>) {
        self.snapshot = snapshot
        self.indexPath = indexPath
        self.offset = offset
        self.listView = listView
    }
    
    func castSnapshotType<SubSource, Item>() -> CollectionContext<SubSource, Item> {
        return .init(listView: listView, indexPath: indexPath, offset: offset, snapshot: snapshot.castType())
    }
}

public extension CollectionContext where SubSource: Collection, SubSource.Element: Source, Item == SubSource.Element.Item {
    func elementsContext() -> CollectionContext<SubSource.Element.SubSource, SubSource.Element.Item> {
        let index = snapshot.index(of: indexPath)
        let subSnapshot = snapshot.elementsSnapshots[index]
        let subOffset = snapshot.elementsOffsets[index]
        let subIndexPath = IndexPath(item: indexPath.item - subOffset.item, section: indexPath.section - subOffset.section)
        return .init(listView: listView, indexPath: subIndexPath, offset: offset.addingOffset(subOffset), snapshot: subSnapshot)
    }
}

public struct TableContext<SubSource, Item>: Context {
    public typealias List = UITableView
    
    public var snapshot: Snapshot<SubSource, Item>
    public var indexPath: IndexPath
    public var offset: IndexPath
    public var listView: UITableView
    
    init(listView: List, indexPath: IndexPath, offset: IndexPath = .default, snapshot: Snapshot<SubSource, Item>) {
        self.snapshot = snapshot
        self.indexPath = indexPath
        self.offset = offset
        self.listView = listView
    }
    
    func castSnapshotType<SubSource, Item>() -> TableContext<SubSource, Item> {
        return .init(listView: listView, indexPath: indexPath, offset: offset, snapshot: snapshot.castType())
    }
}

public extension TableContext where SubSource: Collection, SubSource.Element: Source, Item == SubSource.Element.Item {
    func elementsContext() -> TableContext<SubSource.Element.SubSource, SubSource.Element.Item> {
        let index = snapshot.index(of: indexPath)
        let subSnapshot = snapshot.elementsSnapshots[index]
        let subOffset = snapshot.elementsOffsets[index]
        let subIndexPath = IndexPath(item: indexPath.item - subOffset.item, section: indexPath.section - subOffset.section)
        return .init(listView: listView, indexPath: subIndexPath, offset: offset.addingOffset(subOffset), snapshot: subSnapshot)
    }
}

public extension Context {
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
        storyBoardIdentifier: String,
        indexPath: IndexPath,
        configuration: (CustomCell) -> Void = { _ in }
    ) -> List.Cell {
        return listView.dequeueReusableCell(
            withCellClass: cellClass,
            storyBoardIdentifier: storyBoardIdentifier,
            indexPath: indexPath,
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
