//
//  Context.swift
//  ListKit
//
//  Created by Frain on 2019/10/10.
//

#if os(iOS) || os(tvOS)
import UIKit

public protocol Context {
    associatedtype List: ListView
    associatedtype Source: DataSource
    
    var coordinator: SourceListCoordinator<Source> { get }
    var listView: List { get }
}

public protocol IndexContext: Context {
    var section: Int { get }
    var item: Int { get }
}

public extension IndexContext {
    var listIndexPath: IndexPath {
        fatalError()
    }
    
    func selectItem(animated: Bool, scrollPosition: List.ScrollPosition) {
        listView.selectItem(at: listIndexPath, animated: animated, scrollPosition: scrollPosition)
    }
    
    func deselectItem(animated: Bool) {
        listView.deselectItem(at: listIndexPath, animated: animated)
    }
    
    var cell: List.Cell? {
        return listView.cellForItem(at: listIndexPath)
    }
}

public extension IndexContext {
    func dequeueReusableCell<CustomCell: UIView>(
        withCellClass cellClass: CustomCell.Type,
        identifier: String = "",
        configuration: (CustomCell) -> Void = { _ in }
    ) -> List.Cell {
        listView.dequeueReusableCell(
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
        listView.dequeueReusableCell(
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
        listView.dequeueReusableCell(
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
        listView.dequeueReusableSupplementaryView(
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
        listView.dequeueReusableSupplementaryView(
            type: type,
            withSupplementaryClass: cellClass,
            nibName: nibName,
            bundle: bundle,
            indexPath: listIndexPath,
            configuration: configuration
        )
    }
}

#endif


