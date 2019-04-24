//
//  listContext.swift
//  SundayListKit
//
//  Created by Frain on 2019/4/16.
//  Copyright © 2019 Frain. All rights reserved.
//

public class ListContext<List: ListView> {
    public let listView: List
    public let indexPath: IndexPath
    let offset: IndexPath
    let listViewIndexPath: IndexPath
    let listViewData: ListData
    
    var isUpdateing = false
    var updateClosures = [(List) -> Void]()
    
    public var section: Int {
        return indexPath.section
    }

    public var row: Int {
        return indexPath.row
    }
    
    func model<Model>() -> Model {
        return listViewData.model(at: indexPath)
    }
    
    init(listView: List, listViewData: ListData) {
        self.indexPath = IndexPath(item: 0, section: 0)
        self.offset = IndexPath(item: 0, section: 0)
        self.listViewIndexPath = IndexPath(item: 0, section: 0)
        self.listView = listView
        self.listViewData = listViewData
    }
    
    init(listView: List, indexPath: IndexPath, offset: IndexPath = .init(item: 0, section: 0), listViewIndexPath: IndexPath, listViewData: ListData) {
        self.listView = listView
        self.offset = offset
        self.listViewIndexPath = listViewIndexPath
        self.indexPath = indexPath
        self.listViewData = listViewData
    }
    
    convenience init(listView: List, offset: IndexPath = IndexPath(item: 0, section: 0), listViewIndexPath: IndexPath, listViewData: ListData) {
        let indexPath = IndexPath(item: max(listViewIndexPath.item - offset.item, 0), section: max(listViewIndexPath.section - offset.section, 0))
        self.init(listView: listView, indexPath: indexPath, offset: offset, listViewIndexPath: listViewIndexPath, listViewData: listViewData)
    }
    
    var sublistContext: ListContext<List>? {
        guard let subData = listViewData.subData(at: indexPath) else { return nil }
        let offset = listViewData.subOffset(at: indexPath)
        return ListContext(
            listView: listView,
            indexPath: IndexPath(item: indexPath.item - offset.item, section: indexPath.section - offset.section),
            listViewIndexPath: listViewIndexPath,
            listViewData: subData
        )
    }
}

public extension ListContext {
    func startUpdate() {
        isUpdateing = true
    }
    
    func endUpdate() {
        updateClosures.forEach { $0(listView) }
        updateClosures = []
        isUpdateing = false
    }
    
    func reloadCurrentContext() {
        
    }
    
    func deleteItems(at indexPaths: [IndexPath]) {
        
    }
    
    func insertItems(at indexPaths: [IndexPath]) {
        
    }
    
    func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        
    }
}

public extension ListContext {
    func dequeueReusableCell<CustomCell: UIView>(
        withCellClass cellClass: CustomCell.Type,
        identifier: String = "",
        configuration: (CustomCell) -> Void = { _ in }
    ) -> List.Cell {
        return listView.dequeueReusableCell(
            withCellClass: cellClass,
            identifier: identifier,
            indexPath: listViewIndexPath,
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
            indexPath: listViewIndexPath,
            configuration: configuration
        )
    }
    
    func dequeueReusableHeaderView<CustomSupplementaryView: UIView>(
        withHeaderClass cellClass: CustomSupplementaryView.Type,
        identifier: String = "",
        configuration: (CustomSupplementaryView) -> Void = { _ in }
    ) -> List.SupplementaryView {
        return listView.dequeueReusableHeaderView(
            withHeaderClass: cellClass,
            identifier: identifier,
            indexPath: listViewIndexPath,
            configuration: configuration
        )
    }
    
    func dequeueReusableHeaderView<CustomSupplementaryView: UIView>(
        withHeaderClass cellClass: CustomSupplementaryView.Type,
        nibName: String,
        bundle: Bundle? = nil,
        configuration: (CustomSupplementaryView) -> Void = { _ in }
    ) -> List.SupplementaryView {
        return listView.dequeueReusableHeaderView(
            withHeaderClass: cellClass,
            nibName: nibName,
            bundle: bundle,
            indexPath: listViewIndexPath,
            configuration: configuration
        )
    }
    
    func dequeueReusableFooterView<CustomSupplementaryView: UIView>(
        withFooterClass cellClass: CustomSupplementaryView.Type,
        identifier: String = "",
        indexPath: IndexPath,
        configuration: (CustomSupplementaryView) -> Void = { _ in }
    ) -> List.SupplementaryView {
        return listView.dequeueReusableFooterView(
            withFooterClass: cellClass,
            identifier: identifier,
            indexPath: indexPath,
            configuration: configuration
        )
    }
    
    func dequeueReusableFooterView<CustomSupplementaryView: UIView>(
        withFooterClass cellClass: CustomSupplementaryView.Type,
        nibName: String,
        bundle: Bundle? = nil,
        for indexPath: IndexPath,
        configuration: (CustomSupplementaryView) -> Void = { _ in }
    ) -> List.SupplementaryView {
        return listView.dequeueReusableFooterView(
            withFooterClass: cellClass,
            nibName: nibName,
            bundle: bundle,
            indexPath: indexPath,
            configuration: configuration
        )
    }
}
