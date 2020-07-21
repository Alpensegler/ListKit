//
//  BatchUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/5/7.
//

import Foundation

protocol UpdateCollection {
    init()
    mutating func add(_ other: Self)
}

protocol ListViewApplyable {
    var isEmpty: Bool { get }
    func apply(by listView: ListView)
//    func apply(by )
    func addListDebugDescription(to descriptions: inout [String])
}

protocol UpdateIndexCollection: UpdateCollection, Collection where Element: Hashable {
    static var insert: (ListView) -> (Self) -> Void { get }
    static var delete: (ListView) -> (Self) -> Void { get }
    static var reload: (ListView) -> (Self) -> Void { get }
    static var move: (ListView) -> (Element, Element) -> Void { get }
    
    init(_ element: Element)
    init(_ lower: Element, _ upper: Element)
    
    mutating func add(_ element: Element)
    mutating func add(_ lower: Element, _ upper: Element)
}

protocol BatchUpdate: UpdateCollection, ListViewApplyable { }
protocol IndexBatchUpdate: BatchUpdate {
    typealias Element = Collection.Element
    associatedtype Collection: UpdateIndexCollection
    
    var all: Collection { get set }
}

enum BatchUpdates {
    struct Source<Collection: UpdateIndexCollection>: IndexBatchUpdate {
        var all = Collection()
        private(set) var deletes = Collection()
        var isEmpty: Bool { all.isEmpty }
        
        mutating func add(_ other: Self) {
            if !other.deletes.isEmpty { deletes.add(other.deletes) }
            if !other.all.isEmpty { all.add(other.all) }
        }
        
        mutating func moveOrReload(_ index: Element) {
            all.isEmpty ? all = .init(index) : all.add(index)
        }
        
        mutating func moveOrReload(_ lower: Element, _ upper: Element) {
            all.isEmpty ? all = .init(lower, upper) : all.add(lower, upper)
        }
        
        func apply(by listView: ListView) {
            if deletes.isEmpty { Collection.delete(listView)(deletes) }
        }
        
        func addListDebugDescription(to descriptions: inout [String]) {
            if deletes.isEmpty { return }
            descriptions.append("D \(deletes.map { "\($0)" }.joined(separator: " "))")
        }
    }
    
    struct Target<Collection: UpdateIndexCollection>: IndexBatchUpdate {
        var all = Collection()
        private(set) var inserts = Collection()
        private(set) var reloads = Collection()
        private(set) var moves = [Mapping<Element>]()
        var moveDict = [Element: Element]()
        
        var isEmpty: Bool { all.isEmpty }
        
        mutating func move(_ index: Element, to newIndex: Element) {
            all.isEmpty ? all = .init(newIndex) : all.add(newIndex)
            moves.isEmpty ? moves = [(index, newIndex)] : moves.append((index, newIndex))
            moveDict[newIndex] = index
        }
        
        mutating func move(
            from: (lower: Element, upper: Element),
            to: (lower: Element, upper: Element)
        ) {
            all.isEmpty ? all = .init(to.lower, to.upper) : all.add(to.lower, to.upper)
            let from = Collection(from.lower, from.upper), to = Collection(to.lower, to.upper)
            let movesZips: [Mapping<Element>] = zip(from, to).map { $0 }
            moves.isEmpty ? moves = movesZips : moves.append(contentsOf: movesZips)
            movesZips.forEach { moveDict[$0.target] = $0.source }
        }
        
        mutating func add(_ other: Self) {
            if !other.all.isEmpty { all.add(other.all) }
            if !other.inserts.isEmpty { inserts.add(other.inserts) }
            if !other.reloads.isEmpty { reloads.add(other.reloads) }
            if !other.moves.isEmpty { moves += other.moves }
        }
        
        func apply(by listView: ListView) {
            if inserts.isEmpty { Collection.insert(listView)(inserts) }
            if reloads.isEmpty { Collection.reload(listView)(reloads) }
            if moves.isEmpty { moves.forEach(Collection.move(listView)) }
        }
        
        func addListDebugDescription(to descriptions: inout [String]) {
            if !inserts.isEmpty {
                descriptions.append("I \(inserts.map { "\($0)" }.joined(separator: " "))")
            }
            if !reloads.isEmpty {
                descriptions.append("U \(reloads.map { "\($0)" }.joined(separator: " "))")
            }
            if !moves.isEmpty {
                descriptions.append("M \(moves.map { "(\($0.source), \($0.target))" }.joined(separator: " "))")
            }
        }
    }
    
    struct List<Section: BatchUpdate, Item: BatchUpdate>: BatchUpdate {
        private var itemValue: Item?
        private var sectionValue: Section?
        var isEmpty: Bool { sectionValue.isEmpty && itemValue.isEmpty }
        var item: Item {
            get { itemValue ?? .init() }
            set { itemValue = newValue }
        }
        var section: Section {
            get { sectionValue ?? .init() }
            set { sectionValue = newValue }
        }
        
        init() { }
        
        init(item: Item? = nil, section: Section? = nil) {
            itemValue = item
            sectionValue = section
        }
        
        mutating func add(_ other: Self) {
            itemValue.add(other.itemValue)
            sectionValue.add(other.sectionValue)
        }
        
        func apply(by listView: ListView) {
            itemValue?.apply(by: listView)
            sectionValue?.apply(by: listView)
        }
        
        func addListDebugDescription(to descriptions: inout [String]) {
            if !sectionValue.isEmpty {
                descriptions.append("Section:")
                sectionValue?.addListDebugDescription(to: &descriptions)
            }
            if !itemValue.isEmpty {
                descriptions.append("Item:")
                itemValue?.addListDebugDescription(to: &descriptions)
            }
        }
    }
    
    struct Batch {
        var update: Mapping<ListViewApplyable?>
        var change: (() -> Void)?
        
        var listDebugDescription: String {
            var descriptions = [String]()
            if update.source?.isEmpty == false {
                descriptions.append("Source:")
                update.source?.addListDebugDescription(to: &descriptions)
            }
            if update.target?.isEmpty == false {
                descriptions.append("Target:")
                update.target?.addListDebugDescription(to: &descriptions)
            }
            return descriptions.joined(separator: "\n")
        }
    }

    typealias ItemSource = Source<[IndexPath]>
    typealias ItemTarget = Target<[IndexPath]>
    typealias SectionSource = Source<IndexSet>
    typealias SectionTarget = Target<IndexSet>
    typealias ListSource = List<SectionSource, ItemSource>
    typealias ListTarget = List<SectionTarget, ItemTarget>
    
    case reload(change: (() -> Void)?)
    case batch(ContiguousArray<Batch>)
    
    init(source: ListViewApplyable? = nil, target: ListViewApplyable? = nil, _ change: (() -> Void)?) {
        self = .batch([.init(update: (source, target), change: change)])
    }
}

extension Optional where Wrapped: ListViewApplyable {
    var isEmpty: Bool { self?.isEmpty != false }
}

extension Optional where Wrapped: UpdateCollection {
    mutating func add(_ other: Wrapped?) {
        if var value = self {
            other.map { value.add($0) }
            self = value
        } else {
            self = other
        }
    }
}

extension IndexBatchUpdate {
    mutating func add(_ path: KeyPath<Self, Collection>, _ index: Element) {
//        all.isEmpty ? all = .init(index) : all.add(index)
//        self[keyPath: path].isEmpty
//            ? self[keyPath: path] = .init(index)
//            : self[keyPath: path].add(index)
    }
    
    mutating func add(_ path: KeyPath<Self, Collection>, _ indices: Collection) {
//        all.isEmpty ? all = indices : all.add(indices)
//        self[keyPath: path].isEmpty
//            ? self[keyPath: path] = indices
//            : self[keyPath: path].add(indices)
    }
    
    mutating func add(_ path: KeyPath<Self, Collection>, _ lower: Element, _ upper: Element) {
//        all.isEmpty ? all = indices : all.add(indices)
//        self[keyPath: path].isEmpty
//            ? self[keyPath: path] = indices
//            : self[keyPath: path].add(indices)
    }
    
    init(_ path: KeyPath<Self, Collection>, _ index: Element) {
        self.init()
        add(path, index)
    }
    
    init(_ path: KeyPath<Self, Collection>, _ indices: Collection) {
        self.init()
        add(path, indices)
    }
    
    init(_ path: KeyPath<Self, Collection>, _ lower: Element, _ upper: Element) {
        self.init()
        add(path, lower, upper)
    }
}

extension IndexSet: UpdateIndexCollection {
    
    static var insert: (ListView) -> (IndexSet) -> Void { ListView.insertSections }
    static var delete: (ListView) -> (IndexSet) -> Void { ListView.deleteSections }
    static var reload: (ListView) -> (IndexSet) -> Void { ListView.reloadSections }
    static var move: (ListView) -> (Int, Int) -> Void { ListView.moveSection }
    
    init(_ element: Int) { self.init(integer: element) }
    init(_ from: Int, _ to: Int) { self.init(integersIn: from..<to) }
    
    mutating func add(_ other: IndexSet) { formUnion(other) }
    mutating func add(_ element: Int) { insert(element) }
    mutating func add(_ from: Int, _ to: Int) { insert(integersIn: from..<to) }
}

extension Array: UpdateCollection where Element == IndexPath {
    mutating func add(_ other: Self) { self += other }
}

extension Array: UpdateIndexCollection where Element == IndexPath {
    static var insert: (ListView) -> ([Element]) -> Void { ListView.insertItems }
    static var delete: (ListView) -> ([Element]) -> Void { ListView.deleteItems }
    static var reload: (ListView) -> ([Element]) -> Void { ListView.reloadItems }
    static var move: (ListView) -> (IndexPath, IndexPath) -> Void { ListView.moveItem }
    
    init(_ element: IndexPath) { self = [element] }
    init(_ from: IndexPath, _ to: IndexPath) {
        self = (from.item..<to.item).map { IndexPath(section: from.section, item: $0) }
    }
    
    mutating func add(_ element: IndexPath) { append(element) }
    mutating func add(_ from: IndexPath, _ to: IndexPath) { add(.init(from, to)) }
}
