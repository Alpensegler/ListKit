//
//  Update.swift
//  ListKit
//
//  Created by Frain on 2020/6/7.
//

import Foundation

public struct Update<SourceBase: DataSource> where SourceBase.SourceBase == SourceBase {
    var operations = [(CoordinatorUpdate<SourceBase>) -> Void]()
    var listUpdate: ListUpdate<SourceBase>?
    var source: Source!
    var isEmpty: Bool { listUpdate == nil && operations.isEmpty }
    var isRemove: Bool {
        guard case .remove = listUpdate?.way else { return false }
        return true
    }
}

extension Update: ExpressibleByArrayLiteral, DiffInitializableUpdate {
    init(_ listUpdate: ListUpdate<SourceBase>, _ source: Source) {
        self.listUpdate = listUpdate
        self.source = source
    }
    
    init(_ differ: Differ<SourceBase.Item>?, or update: ListUpdate<SourceBase>? = nil) {
        listUpdate = differ.map { .init(diff: $0) } ?? update
    }
}

public extension Update {
    typealias Item = SourceBase.Item
    typealias Value = SourceBase.Item
    typealias Source = SourceBase.Source
    
    static var remove: Self { .init(.init(way: .remove)) }
    static func reload(to source: Source) -> Self { .init(.init(way: .reload), source) }
    
    init(arrayLiteral elements: Self...) {
        elements.forEach { add($0) }
    }
    
    init(_ listUpdate: ListUpdate<SourceBase>) {
        self.listUpdate = listUpdate
    }
    
    mutating func add(_ other: Self) {
        operations += other.operations
        listUpdate = other.listUpdate ?? listUpdate
        source = other.source ?? source
    }
}

public extension Update where Source: Collection {
    typealias Element = SourceBase.Source.Element
    typealias Index = SourceBase.Source.Index
    
    static func appendOrRemoveLast(to source: Source) -> Self {
        .init(.init(way: .appendOrRemoveLast), source)
    }
    
    static func prependOrRemoveFirst(to source: Source) -> Self {
        .init(.init(way: .prependOrRemoveFirst), source)
    }
}

public extension Update
where Source: RangeReplaceableCollection, Source.Element == SourceBase.Item {
    internal init(operation: @escaping (ItemsCoordinatorUpdate<SourceBase>) -> Void) {
        operations.append { ($0 as? ItemsCoordinatorUpdate<SourceBase>).map(operation) }
    }
    
    static func insert(_ item: Item, at index: Index) -> Self {
        .init { $0.insert(item, at: index) }
    }
    
    static func insert<C: Collection>(contentsOf elements: C, at index: Index) -> Self
    where C.Element == Item {
        .init { $0.insert(contentsOf: elements, at: index) }
    }
    
    static func append(_ element: Item) -> Self {
        .init { $0.append(element) }
    }
    
    static func append<S: Sequence>(contentsOf items: S) -> Self where S.Element == Item {
        .init { $0.append(contentsOf: items) }
    }
    
    static func remove(at index: Index) -> Self {
        .init { $0.remove(at: index) }
    }
    
    static func update(_ item: Item, at index: Index) -> Self {
        .init { $0.update(item, at: index) }
    }
    
    static func move(at index: Index, to newIndex: Index) -> Self {
        .init { $0.move(at: index, to: newIndex) }
    }
}

public extension Update
where
    Source: RangeReplaceableCollection,
    Source.Element: DataSource,
    Source.Element.SourceBase.Item == SourceBase.Item
{
    internal init(
        operation: @escaping (SourcesCoordinatorUpdate<SourceBase, SourceBase.Source>) -> Void
    ) {
        operations.append {
            ($0 as? SourcesCoordinatorUpdate<SourceBase, SourceBase.Source>).map(operation)
        }
    }
    
    static func subsource<Subsource: UpdatableDataSource>(
        _ source: Subsource,
        update: Update<Subsource.SourceBase>,
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
    
    static func insert(_ element: Element, at index: Index) -> Self {
        .init { $0.insert(element, at: index) }
    }
    
    static func insert<C: Collection>(contentsOf elements: C, at index: Index) -> Self
    where Element == C.Element {
        .init { $0.insert(contentsOf: elements, at: index) }
    }
    
    static func append(_ element: Element) -> Self {
        .init { $0.append(element) }
    }
    
    static func append<S: Sequence>(contentsOf elements: S) -> Self where Element == S.Element {
        .init { $0.append(contentsOf: elements) }
    }
    
    static func remove(at index: Index) -> Self {
        .init { $0.remove(at: index) }
    }
    
    static func update(_ element: Element, at index: Index) -> Self {
        .init { $0.update(element, at: index) }
    }
    
    static func move(at index: Index, to newIndex: Index) -> Self {
        .init { $0.move(at: index, to: newIndex) }
    }
}

public extension Update where SourceBase: NSDataSource {
    internal init(operation: @escaping (NSCoordinatorUpdate<SourceBase>) -> Void) {
        operations.append { ($0 as? NSCoordinatorUpdate<SourceBase>).map(operation) }
    }
    
    static func insertSection(_ section: Int) -> Self {
        .init { $0.insertSection(section) }
    }
    
    static func insertSections(_ sections: IndexSet) -> Self {
        .init { $0.insertSections(sections) }
    }
    
    static func deleteSection(_ section: Int) -> Self {
        .init { $0.deleteSection(section) }
    }
    
    static func deleteSections(_ sections: IndexSet) -> Self {
        .init { $0.deleteSections(sections) }
    }
    
    static func reloadSection(_ section: Int) -> Self {
        .init { $0.reloadSection(section) }
    }
    
    static func reloadSections(_ sections: IndexSet) -> Self {
        .init { $0.reloadSections(sections) }
    }
    
    static func moveSection(_ section: Int, toSection newSection: Int) -> Self {
        .init { $0.moveSection(section, to: newSection) }
    }
    
    static func insertItem(at indexPath: IndexPath) -> Self {
        .init { $0.insertItem(at: indexPath) }
    }
    
    static func insertItems(at indexPaths: [IndexPath]) -> Self {
        .init { $0.insertItems(at: indexPaths) }
    }
    
    static func deleteItem(at indexPath: IndexPath) -> Self {
        .init { $0.deleteItem(at: indexPath) }
    }
    
    static func deleteItems(at indexPaths: [IndexPath]) -> Self {
        .init { $0.deleteItems(at: indexPaths) }
    }
    
    static func reloadItem(at indexPath: IndexPath) -> Self {
        .init { $0.reloadItem(at: indexPath) }
    }
    
    static func reloadItems(at indexPaths: [IndexPath]) -> Self {
        .init { $0.reloadItems(at: indexPaths) }
    }
    
    static func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath) -> Self {
        .init { $0.moveItem(at: indexPath, to: newIndexPath) }
    }
}

//Value Equatable
public extension Update where Value: Equatable {
    static func diff(to source: Source) -> Self { .init(.diff(by: ==), source) }
    static func diff<ID: Hashable>(to source: Source, id: @escaping (Value) -> ID) -> Self {
        .init(.diff(id: id, by: ==), source)
    }
}

//Value Hashable
public extension Update where Value: Hashable {
    static func diff(to source: Source) -> Self { .init(.diff(id: { $0 }), source) }
}

//Value Identifiable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Update where Value: Identifiable {
    static func diff(to source: Source) -> Self { .init(.diff(id: \.id), source) }
    static func diff(
        to source: Source,
        by areEquivalent: @escaping (Value, Value) -> Bool
    ) -> Self {
        .init(.diff(id: \.id, by: areEquivalent), source)
    }
}

//Value Identifiable + Equatable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Update where Value: Identifiable, Value: Equatable {
    static func diff(to source: Source) -> Self { .init(.diff(id: \.id, by: ==), source) }
}

//Value Identifiable + Hashable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Update where Value: Identifiable, Value: Hashable {
    static func diff(to source: Source) -> Self { .init(.diff(id: \.id, by: ==), source) }
}
