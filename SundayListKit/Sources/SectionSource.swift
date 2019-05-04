//
//  SectionSource.swift
//  SundayListKit
//
//  Created by Frain on 2019/6/8.
//  Copyright © 2019 Frain. All rights reserved.
//

#if iOS13
import SwiftUI
#endif

public protocol SectionSource: CollectionSource where Snapshot == SectionSnapshot<Self, Item> { }
public protocol SectionDataSource: SectionSource, DataSource where Item == ViewModel { }
public protocol SectionAdapter: SectionDataSource, Adapter { }

public extension SectionSource {
    func snapshot<List: ListView>(for listView: List) -> SectionSnapshot<Self, Item> {
        return SectionSnapshot(self, for: listView)
    }
    func item<List: ListView>(for context: ListIndexContext<List, Self>) -> Item {
        return context.element()
    }
}

public extension SectionSource where Item: Source {
    func snapshot<List: ListView>(for listView: List) -> SectionSnapshot<Self, Item> {
        return SectionSnapshot(self, for: listView)
    }
}

public extension SectionDataSource {
    func viewModel<List: ListView>(for context: ListIndexContext<List, Self>) -> Item {
        return item(for: context)
    }
}

public struct SectionSnapshot<Value, Element>: CollectionSnapshot {
    public typealias Item = Element
    public let subSource: [Element]
    public let subSnapshots: [Any]
    public let value: Value
    
    public init<List: ListView>(_ source: Value, for listView: List) where Value: CollectionSource, Value.Element == Element {
        self.subSource = Array(source.source(for: listView))
        self.value = source
        self.subSnapshots = []
    }
    
    public init<List: ListView>(_ source: Value, for listView: List) where Value: CollectionSource, Value.Element == Element, Element: Source {
        var subSource = [Element]()
        var snapshots = [Element.Snapshot]()
        for sub in source.source(for: listView) {
            subSource.append(sub)
            snapshots.append(sub.snapshot(for: listView))
        }
        self.subSource = subSource
        self.subSnapshots = snapshots
        self.value = source
    }
    
    public func numbersOfSections() -> Int {
        return 1
    }
    
    public func numbersOfItems(in section: Int) -> Int {
        return subSource.count
    }
    
    public func element(for indexPath: IndexPath) -> Element {
        return subSource[indexPath.item]
    }
    
    public func elementSnaphot(for indexPath: IndexPath) -> Any {
        return subSnapshots[indexPath.item]
    }
    
    public func elementOffset(for indexPath: IndexPath) -> IndexPath {
        return indexPath
    }
}

extension SectionSnapshot: Equatable where Value: Equatable { }
extension SectionSnapshot: Identifiable where Value: Identifiable { }
