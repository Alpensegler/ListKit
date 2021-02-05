//
//  BatchInitializable.swift
//  ListKit
//
//  Created by Frain on 2020/7/24.
//

import Foundation

public protocol BatchInitializable: ExpressibleByArrayLiteral
where ArrayLiteralElement == ListUpdate<SourceBase>.Batch {
    associatedtype SourceBase: DataSource where SourceBase.SourceBase == SourceBase
    typealias Item = SourceBase.Item
    typealias Value = SourceBase.Item
    typealias Source = SourceBase.Source
    
    var batch: ListUpdate<SourceBase>.Batch? { get }
    
    init(_ batch: ListUpdate<SourceBase>.Batch)
}

public extension BatchInitializable {
    init(arrayLiteral elements: ListUpdate<SourceBase>.Batch...) {
        let operations = elements.flatMap { $0.operations }
        self = .init(.init(operations: operations, needSource: elements.contains { $0.needSource }))
    }
    
    mutating func add(_ other: ListUpdate<SourceBase>.Batch) {
        self = .init(.init(
            operations: (batch?.operations ?? []) + other.operations,
            needSource: (batch?.needSource ?? false) || other.needSource
        ))
    }
}

extension BatchInitializable {
    init(needSource: Bool = false, closure: @escaping (ListCoordinatorUpdate<SourceBase>) -> Void) {
        self.init(.init(operations: [closure], needSource: needSource))
    }
    
    init(section: ChangeSets<IndexSet>?, item: ChangeSets<IndexPathSet>?) {
        self.init(needSource: true) { update in
            section.map { update.section = $0 }
            item.map { update.item = $0 }
        }
    }
}

public extension BatchInitializable
where Source: RangeReplaceableCollection, Source.Element == SourceBase.Item {
    static func insert(_ item: Item, at index: Int) -> Self {
        .init { $0.insert(item, at: index) }
    }
    
    static func insert<C: Collection>(contentsOf elements: C, at index: Int) -> Self
    where C.Element == Item {
        .init { $0.insert(contentsOf: elements, at: index) }
    }
    
    static func append(_ element: Item) -> Self {
        .init { $0.append(element) }
    }
    
    static func append<S: Sequence>(contentsOf items: S) -> Self where S.Element == Item {
        .init { $0.append(contentsOf: items) }
    }
    
    static func remove(at index: Int) -> Self {
        .init { $0.remove(at: index) }
    }
    
    static func remove(at indexSet: IndexSet) -> Self {
        .init { $0.remove(at: indexSet) }
    }
    
    static func update(_ item: Item, at index: Int) -> Self {
        .init { $0.update(item, at: index) }
    }
    
    static func move(at index: Int, to newIndex: Int) -> Self {
        .init { $0.move(at: index, to: newIndex) }
    }
}

public extension BatchInitializable
where
    Source: RangeReplaceableCollection,
    Source.Element: DataSource,
    Source.Element.SourceBase.Item == SourceBase.Item
{
    typealias Element = SourceBase.Source.Element
    
    static func subsource<Subsource: UpdatableDataSource>(
        _ source: Subsource,
        update: ListUpdate<Subsource.SourceBase>,
        animatedForOtherContext: Bool? = nil,
        completionForOtherContext: ((ListView, Bool) -> Void)? = nil
    ) -> Self {
        .init {
            $0.subsource(
                source,
                update: update,
                animated: animatedForOtherContext,
                completion: completionForOtherContext
            )
        }
    }
    
    static func insert(_ element: Element, at index: Int) -> Self {
        .init { $0.insert(element, at: index) }
    }
    
    static func insert<C: Collection>(contentsOf elements: C, at index: Int) -> Self
    where Element == C.Element {
        .init { $0.insert(contentsOf: elements, at: index) }
    }
    
    static func append(_ element: Element) -> Self {
        .init { $0.append(element) }
    }
    
    static func append<S: Sequence>(contentsOf elements: S) -> Self where Element == S.Element {
        .init { $0.append(contentsOf: elements) }
    }
    
    static func remove(at index: Int) -> Self {
        .init { $0.remove(at: index) }
    }
    
    static func remove(at indexSet: IndexSet) -> Self {
        .init { $0.remove(at: indexSet) }
    }
    
    static func update(_ element: Element, at index: Int) -> Self {
        .init { $0.update(element, at: index) }
    }
    
    static func move(at index: Int, to newIndex: Int) -> Self {
        .init { $0.move(at: index, to: newIndex) }
    }
}

public extension BatchInitializable where SourceBase: NSDataSource {
    static func insertSection(_ section: Int) -> Self {
        .init(needSource: true) { $0.section.insert(section) }
    }
    
    static func insertSections(_ sections: IndexSet) -> Self {
        .init(needSource: true) { $0.section.insert(sections) }
    }
    
    static func deleteSection(_ section: Int) -> Self {
        .init(needSource: true) { $0.section.delete(section) }
    }
    
    static func deleteSections(_ sections: IndexSet) -> Self {
        .init(needSource: true) { $0.section.delete(sections) }
    }
    
    static func reloadSection(_ section: Int, newSection: Int? = nil) -> Self {
        .init(needSource: true) { $0.section.reload(section, newIndex: newSection ?? section) }
    }
    
    static func reloadSections(_ sections: IndexSet, newSections: IndexSet? = nil) -> Self {
        .init(needSource: true) { $0.section.reload(sections, newIndices: newSections ?? sections) }
    }
    
    static func moveSection(_ section: Int, toSection newSection: Int) -> Self {
        .init(needSource: true) { $0.section.move(section, to: newSection) }
    }
    
    static func insertItem(at indexPath: IndexPath) -> Self {
        .init(needSource: true) { $0.item.insert(indexPath) }
    }
    
    static func insertItems(at indexPaths: [IndexPath]) -> Self {
        .init(needSource: true) { $0.item.insert(indexPaths) }
    }
    
    static func deleteItem(at indexPath: IndexPath) -> Self {
        .init(needSource: true) { $0.item.delete(indexPath) }
    }
    
    static func deleteItems(at indexPaths: [IndexPath]) -> Self {
        .init(needSource: true) { $0.item.delete(indexPaths) }
    }
    
    static func reloadItem(at indexPath: IndexPath, newIndexPath: IndexPath? = nil) -> Self {
        .init(needSource: true) { $0.item.reload(indexPath, newIndex: newIndexPath ?? indexPath) }
    }
    
    static func reloadItems(at indexPaths: [IndexPath], newIndexPaths: [IndexPath]? = nil) -> Self {
        .init(needSource: true) { $0.item.reload(indexPaths, newIndices: newIndexPaths ?? indexPaths) }
    }
    
    static func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath) -> Self {
        .init(needSource: true) { $0.item.move(indexPath, to: newIndexPath) }
    }
}

public extension BatchInitializable
where
    Source: DataSource,
    Source.SourceBase == AnySources,
    Item == Any
{
    static func subsource<Subsource: UpdatableDataSource>(
        _ source: Subsource,
        update: ListUpdate<Subsource.SourceBase>,
        animatedForOtherContext: Bool? = nil,
        completionForOtherContext: ((ListView, Bool) -> Void)? = nil
    ) -> Self {
        .init {
            $0.subsource(
                source,
                update: update,
                animated: animatedForOtherContext,
                completion: completionForOtherContext
            )
        }
    }
}
