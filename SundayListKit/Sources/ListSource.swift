//
//  ListSource.swift
//  SundayListKit
//
//  Created by Frain on 2019/6/8.
//  Copyright © 2019 Frain. All rights reserved.
//

#if iOS13
import SwiftUI
#endif

public protocol ListSource: MultiSectionSource, CollectionSource { }
public protocol ListDataSource: ListSource, DataSource where Element == ViewModel { }
public protocol ListAdapter: ListDataSource, Adapter { }

public protocol SourceCollectionSnapshot: CollectionSnapshot { }

public extension ListSource where Element == Item {
    func snapshot<List: ListView>(for listView: List) -> ListSnapshot<Self, Element> {
        return ListSnapshot(self, for: listView)
    }
    
    func item<List: ListView>(for context: ListIndexContext<List, Self>) -> Item {
        return context.element()
    }
}

public extension ListSource where Element: Source, Element == Item {
    func snapshot<List: ListView>(for listView: List) -> ListSnapshot<Self, Element> {
        return ListSnapshot(self, for: listView)
    }
    
    func item<List: ListView>(for context: ListIndexContext<List, Self>) -> Item {
        return context.element()
    }
}

public extension ListSource where Element: Source, Item == Element.Item {
    func snapshot<List: ListView>(for listView: List) -> ListSnapshot<Self, Element> {
        return ListSnapshot(self, for: listView)
    }
    
    func item<List: ListView>(for context: ListIndexContext<List, Self>) -> Item {
        return context.elementItem()
    }
}

public extension ListSource where Element: Source, Item == Element.Item, Element.Item == Element {
    func snapshot<List: ListView>(for listView: List) -> ListSnapshot<Self, Element> {
        return ListSnapshot(self, for: listView)
    }
    
    func item<List: ListView>(for context: ListIndexContext<List, Self>) -> Item {
        return context.elementItem()
    }
}

public extension ListSource where Element: Source, Item == Never {
    func snapshot<List: ListView>(for listView: List) -> ListSnapshot<Self, Element> {
        return ListSnapshot(self, for: listView)
    }
    
    func item<List: ListView>(for context: ListIndexContext<List, Self>) -> Item {
        fatalError("unimplemented")
    }
}

public extension ListDataSource {
    func viewModel<List: ListView>(for context: ListIndexContext<List, Self>) -> Element {
        return context.element()
    }
}

public struct ListSnapshot<Value, Element>: SourceCollectionSnapshot, CollectionSnapshot {
    public let subSource: [Element]
    public let subSnapshots: [Any]
    
    let subSourceIndices: [[Int]]
    let subSourceOffsets: [IndexPath]
    
    public func element(for indexPath: IndexPath) -> Element {
        return subSource[subSourceIndices[indexPath]]
    }
    
    public func elementSnaphot(for indexPath: IndexPath) -> Any {
        return subSnapshots[subSourceIndices[indexPath]]
    }
    
    public func elementOffset(for indexPath: IndexPath) -> IndexPath {
        return subSourceOffsets[subSourceIndices[indexPath]]
    }
    
    public func numbersOfSections() -> Int {
        return subSourceIndices.count
    }
    
    public func numbersOfItems(in section: Int) -> Int {
        return subSourceIndices[safe: section]?.count ?? 0
    }
    
    public init<List: ListView>(_ source: Value, for listView: List) where Value: CollectionSource, Value.Element == Element {
        self.subSource = Array(source.source(for: listView))
        self.subSnapshots = []
        self.subSourceIndices = [Array(subSource.indices)]
        self.subSourceOffsets = subSource.indices.map { IndexPath(item: $0) }
    }
    
    public init<List: ListView>(_ source: Value, for listView: List) where Value: CollectionSource, Value.Element == Element, Element: Source {
        let subSourceCollection = source.source(for: listView)
        var subSource = [Element]()
        var subSnapshots = [Element.Snapshot]()
        var subSourceIndices = [[Int]]()
        var subSourceOffsets = [IndexPath]()
        var offset = IndexPath(item: 0, section: 0)
        var lastSourceWasSection = false
        
        for source in subSourceCollection {
            let snapshot = source.snapshot(for: listView)
            let sectionCount = snapshot.numbersOfSections()
            if sectionCount > 0 {
                if offset.item > 0 {
                    offset = IndexPath(item: 0, section: offset.section + 1)
                }
                subSourceOffsets.append(offset)
                lastSourceWasSection = true
                for i in 0..<sectionCount {
                    subSourceIndices.append(Array(repeating: subSource.lastIndex, count: snapshot.numbersOfItems(in: i)))
                }
                offset.section += sectionCount
            } else {
                subSourceOffsets.append(offset)
                lastSourceWasSection = false
                let cellCount = snapshot.numbersOfItems(in: 0)
                if subSourceIndices.isEmpty || lastSourceWasSection {
                    subSourceIndices.append(Array(repeating: subSource.lastIndex, count: cellCount))
                } else {
                    subSourceIndices[subSourceIndices.lastIndex].append(contentsOf: Array(repeating: subSource.lastIndex, count: cellCount))
                }
                offset.item += cellCount
            }
            subSource.append(source)
            subSnapshots.append(snapshot)
        }
        
        self.subSource = subSource
        self.subSnapshots = subSnapshots
        self.subSourceIndices = subSourceIndices
        self.subSourceOffsets = subSourceOffsets
    }
}


private extension Array {
    var lastIndex: Int {
        return Swift.max(endIndex - 1, 0)
    }
}


