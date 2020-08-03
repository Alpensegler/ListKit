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

protocol ListViewApplyable: CustomStringConvertible, CustomDebugStringConvertible {
    var isEmpty: Bool { get }
    var listDebugDescriptions: [String] { get }
    func apply(by listView: ListView)
    func apply<Cache>(
        by caches: inout ContiguousArray<ContiguousArray<Cache?>>,
        _ itemMoves: [IndexPath: Cache?],
        _ sectionMoves: [Int: ContiguousArray<Cache?>],
        countIn: (Int) -> Int
    )
    
    func add<Cache>(
        from caches: inout ContiguousArray<ContiguousArray<Cache?>>,
        _ itemMoves: inout [IndexPath: Cache?],
        _ sectionMoves: inout [Int: ContiguousArray<Cache?>]
    )
}

extension ListViewApplyable {
    var description: String { listDebugDescriptions.joined(separator: "\n") }
    var debugDescription: String { description }
    
    func applyData() { }
}

protocol UpdateIndexCollection: UpdateCollection, BidirectionalCollection where Element: ListIndex {
    static func insert(_ value: Self, by listView: ListView)
    static func delete(_ value: Self, by listView: ListView)
    static func reload(_ value: Self, by listView: ListView)
    static func move(_ element: Mapping<Element>, by listView: ListView)
    
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
    var isEmpty: Bool { get set }
}

enum BatchUpdates {
    struct Source<Collection: UpdateIndexCollection>: IndexBatchUpdate {
        var all = Collection()
        var deletes = Collection()
        var reloads = Collection()
        var isEmpty = true
        
        init() { }
        
        init(move index: Element) {
            all = .init(index)
        }
        
        mutating func add(_ other: Self) {
            if !other.deletes.isEmpty { deletes.add(other.deletes) }
            if !other.reloads.isEmpty { reloads.add(other.reloads) }
            if !other.all.isEmpty { all.add(other.all) }
            isEmpty = isEmpty && other.isEmpty
        }
        
        mutating func move(_ index: Element) {
            all.isEmpty ? all = .init(index) : all.add(index)
        }
        
        mutating func move(_ lower: Element, _ upper: Element) {
            all.isEmpty ? all = .init(lower, upper) : all.add(lower, upper)
        }
        
        func apply(by listView: ListView) {
            if !deletes.isEmpty { Collection.delete(deletes, by: listView) }
            if !reloads.isEmpty { Collection.reload(reloads, by: listView) }
        }
        
        func add<Cache>(
            from caches: inout ContiguousArray<ContiguousArray<Cache?>>,
            _ itemMoves: inout [IndexPath: Cache?],
            _ sectionMoves: inout [Int: ContiguousArray<Cache?>]
        ) {
            
        }
        
        func apply<Cache>(
            by caches: inout ContiguousArray<ContiguousArray<Cache?>>,
            _ itemMoves: [IndexPath: Cache?],
            _ sectionMoves: [Int: ContiguousArray<Cache?>],
            countIn: (Int) -> Int
        ) {
            all.reversed().forEach { $0.remove(from: &caches) }
        }
        
        var listDebugDescriptions: [String] {
            var descriptions = [String]()
            if !deletes.isEmpty {
                descriptions.append("D \(deletes.map { "\($0)" }.joined(separator: " "))")                
            }
            if !reloads.isEmpty {
                descriptions.append("U \(reloads.map { "\($0)" }.joined(separator: " "))")
            }
            return descriptions
        }
    }
    
    struct Target<Collection: UpdateIndexCollection>: IndexBatchUpdate {
        var all = Collection()
        var inserts = Collection()
        var moves = [Mapping<Element>]()
        var moveDict = [Element: Element]()
        var isEmpty = true
        
        init() { }
        
        init(move index: Element, to newIndex: Element) {
            all = .init(newIndex)
            moves = [(index, newIndex)]
            moveDict[newIndex] = index
            guard index != newIndex else { return }
            isEmpty = false
        }
        
        mutating func move(_ index: Element, to newIndex: Element) {
            all.isEmpty ? all = .init(newIndex) : all.add(newIndex)
            moves.isEmpty ? moves = [(index, newIndex)] : moves.append((index, newIndex))
            moveDict[newIndex] = index
            guard index != newIndex else { return }
            isEmpty = false
        }
        
        mutating func move(_ lower: Mapping<Element>, _ upper: Mapping<Element>) {
            all.isEmpty
                ? all = .init(lower.target, upper.target)
                : all.add(lower.target, upper.target)
            let from = Collection(lower.source, upper.source)
            let to = Collection(lower.target, upper.target)
            let movesZips: [Mapping<Element>] = zip(from, to).map { $0 }
            moves.isEmpty ? moves = movesZips : moves.append(contentsOf: movesZips)
            movesZips.forEach { moveDict[$0.target] = $0.source }
            guard lower != upper else { return }
            isEmpty = false
        }
        
        mutating func reload(_ newIndex: Element) {
            all.isEmpty ? all = .init(newIndex) : all.add(newIndex)
            isEmpty = false
        }
        
        mutating func reload(_ lower: Element, _ upper: Element) {
            all.isEmpty ? all = .init(lower, upper) : all.add(lower, upper)
            isEmpty = false
        }
        
        mutating func add(_ other: Self) {
            if !other.all.isEmpty { all.add(other.all) }
            if !other.inserts.isEmpty { inserts.add(other.inserts) }
            if !other.moves.isEmpty { moves += other.moves }
            isEmpty = isEmpty && other.isEmpty
        }
        
        func apply(by listView: ListView) {
            if !inserts.isEmpty { Collection.insert(inserts, by: listView) }
            if !moves.isEmpty { moves.forEach { Collection.move($0, by: listView)} }
        }
        
        func add<Cache>(
            from caches: inout ContiguousArray<ContiguousArray<Cache?>>,
            _ itemMoves: inout [IndexPath: Cache?],
            _ sectionMoves: inout [Int: ContiguousArray<Cache?>]
        ) {
            moves.forEach { $0.target.add($0.source, from: &caches, &itemMoves, &sectionMoves) }
        }
        
        func apply<Cache>(
            by caches: inout ContiguousArray<ContiguousArray<Cache?>>,
            _ itemMoves: [IndexPath: Cache?],
            _ sectionMoves: [Int: ContiguousArray<Cache?>],
            countIn: (Int) -> Int
        ) {
            all.forEach { $0.insert(to: &caches, itemMoves, sectionMoves, countIn: countIn) }
        }
        
        var listDebugDescriptions: [String] {
            var descriptions = [String]()
            if !inserts.isEmpty {
                descriptions.append("I \(inserts.map { "\($0)" }.joined(separator: " "))")
            }
            if !moves.isEmpty {
                descriptions.append("M \(moves.map { "(\($0.source), \($0.target))" }.joined(separator: " "))")
            }
            return descriptions
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
        
        func add<Cache>(
            from caches: inout ContiguousArray<ContiguousArray<Cache?>>,
            _ itemMoves: inout [IndexPath: Cache?],
            _ sectionMoves: inout [Int: ContiguousArray<Cache?>]
        ) {
            itemValue?.add(from: &caches, &itemMoves, &sectionMoves)
            sectionValue?.add(from: &caches, &itemMoves, &sectionMoves)
        }
        
        func apply<Cache>(
            by caches: inout ContiguousArray<ContiguousArray<Cache?>>,
            _ itemMoves: [IndexPath: Cache?],
            _ sectionMoves: [Int: ContiguousArray<Cache?>],
            countIn: (Int) -> Int
        ) {
            itemValue?.apply(by: &caches, itemMoves, sectionMoves, countIn: countIn)
            sectionValue?.apply(by: &caches, itemMoves, sectionMoves, countIn: countIn)
        }
        
        var listDebugDescriptions: [String] {
            var descriptions = [String]()
            if let sections = sectionValue?.listDebugDescriptions, !sections.isEmpty {
                descriptions.append("Section:")
                descriptions += sections
            }
            if let items = itemValue?.listDebugDescriptions, !items.isEmpty {
                descriptions.append("Item:")
                descriptions += items
            }
            return descriptions
        }
    }
    
    struct Batch: ListViewApplyable {
        var update: Mapping<ListViewApplyable?>
        var change: (() -> Void)?
        var isEmpty: Bool { false }
            
        
        var listDebugDescriptions: [String] {
            var descriptions = [String]()
            if let sources = update.source?.listDebugDescriptions, !sources.isEmpty {
                descriptions.append("Source:")
                descriptions += sources
            }
            if let targets = update.target?.listDebugDescriptions, !targets.isEmpty {
                descriptions.append("Target:")
                descriptions += targets
            }
            return descriptions
        }
        
        func applyData() {
            change?()
        }
        
        func apply(by listView: ListView) {
            update.source?.apply(by: listView)
            update.target?.apply(by: listView)
        }
        
        func add<Cache>(
            from caches: inout ContiguousArray<ContiguousArray<Cache?>>,
            _ itemMoves: inout [IndexPath: Cache?],
            _ sectionMoves: inout [Int: ContiguousArray<Cache?>]
        ) {
            update.target?.add(from: &caches, &itemMoves, &sectionMoves)
        }
        
        func apply<Cache>(
            by caches: inout ContiguousArray<ContiguousArray<Cache?>>,
            _ itemMoves: [IndexPath: Cache?],
            _ sectionMoves: [Int: ContiguousArray<Cache?>],
            countIn: (Int) -> Int
        ) {
            update.source?.apply(by: &caches, itemMoves, sectionMoves, countIn: countIn)
            update.target?.apply(by: &caches, itemMoves, sectionMoves, countIn: countIn)
        }
        
        func apply<Cache>(
            caches: inout ContiguousArray<ContiguousArray<Cache?>>,
            countIn: (Int) -> Int,
            applyData: (Self) -> Void = { $0.applyData() }
        ) {
            var itemCaches = [IndexPath: Cache?](), sectionCaches = [Int: ContiguousArray<Cache?>]()
            add(from: &caches, &itemCaches, &sectionCaches)
            applyData(self)
            apply(by: &caches, itemCaches, sectionCaches, countIn: countIn)
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
    mutating func add(_ path: WritableKeyPath<Self, Collection>, _ index: Element) {
        all.isEmpty ? all = .init(index) : all.add(index)
        self[keyPath: path].isEmpty
            ? self[keyPath: path] = .init(index)
            : self[keyPath: path].add(index)
        isEmpty = false
    }
    
    mutating func add(_ path: WritableKeyPath<Self, Collection>, _ indices: Collection) {
        all.isEmpty ? all = indices : all.add(indices)
        self[keyPath: path].isEmpty
            ? self[keyPath: path] = indices
            : self[keyPath: path].add(indices)
        isEmpty = false
    }
    
    mutating func add(_ path: WritableKeyPath<Self, Collection>, _ lower: Element, _ upper: Element) {
        all.isEmpty ? all = .init(lower, upper) : all.add(lower, upper)
        self[keyPath: path].isEmpty
            ? self[keyPath: path] = .init(lower, upper)
            : self[keyPath: path].add(lower, upper)
        isEmpty = false
    }
    
    init(_ path: WritableKeyPath<Self, Collection>, _ index: Element) {
        self.init()
        add(path, index)
    }
    
    init(_ path: WritableKeyPath<Self, Collection>, _ indices: Collection) {
        self.init()
        add(path, indices)
    }
    
    init(_ path: WritableKeyPath<Self, Collection>, _ lower: Element, _ upper: Element) {
        self.init()
        add(path, lower, upper)
    }
}

extension IndexSet: UpdateIndexCollection {
    static func insert(_ value: Self, by listView: ListView) { listView.insertSections(value) }
    static func delete(_ value: Self, by listView: ListView) { listView.deleteSections(value) }
    static func reload(_ value: Self, by listView: ListView) { listView.reloadSections(value) }
    static func move(_ element: Mapping<Int>, by listView: ListView) {
        listView.moveSection(element.source, toSection: element.target)
    }
    
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
    static func insert(_ value: Self, by listView: ListView) { listView.insertItems(at: value) }
    static func delete(_ value: Self, by listView: ListView) { listView.deleteItems(at: value) }
    static func reload(_ value: Self, by listView: ListView) { listView.reloadItems(at: value) }
    static func move(_ element: Mapping<IndexPath>, by listView: ListView) {
        listView.moveItem(at: element.source, to: element.target)
    }
    
    init(_ element: IndexPath) { self = [element] }
    init(_ from: IndexPath, _ to: IndexPath) {
        self = (from.item..<to.item).map { IndexPath(section: from.section, item: $0) }
    }
    
    mutating func add(_ element: IndexPath) { append(element) }
    mutating func add(_ from: IndexPath, _ to: IndexPath) { add(.init(from, to)) }
}
