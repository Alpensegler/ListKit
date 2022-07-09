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

protocol UpdateIndexCollection: UpdateCollection {
    associatedtype Element: ListIndex
    associatedtype Elements where Elements: BidirectionalCollection, Elements.Element == Element

    static func insert(_ elements: Elements, by list: ListView)
    static func delete(_ elements: Elements, by list: ListView)
    static func reload(_ elements: Elements, by list: ListView)
    static func move(_ element: Mapping<Element>, by list: ListView)

    var isEmpty: Bool { get }

    init()
    init(_ element: Element)
    init(_ elements: Elements)
    init(_ lower: Element, _ upper: Element)

    mutating func add(_ element: Element)
    mutating func add(_ elements: Elements)
    mutating func add(_ lower: Element, _ upper: Element)

    func elements(_ offset: Element?) -> Elements
}

extension UpdateIndexCollection {
    func descriptions(with offset: Element?) -> String {
        elements(offset).map { "\($0)" }.joined(separator: " ")
    }
}

protocol BatchUpdate: UpdateCollection, ListViewApplyable { }
protocol IndexBatchUpdate: BatchUpdate {
    typealias Element = Collection.Element
    associatedtype Collection: UpdateIndexCollection

    var isEmpty: Bool { get set }
}

enum BatchUpdates {
    typealias ItemSource = Source<IndexPathSet>
    typealias ItemTarget = Target<IndexPathSet>
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

extension BatchUpdates {
    struct Source<Collection: UpdateIndexCollection>: IndexBatchUpdate {
        var offset: Collection.Element?
        var moves = Collection()
        var deletes = Collection()
        var reloads = Collection()
        var isEmpty = true
        var all: Collection {
            var all = Collection()
            if !moves.isEmpty { all.add(moves) }
            if !deletes.isEmpty { all.add(deletes) }
            if !reloads.isEmpty { all.add(reloads) }
            return all
        }

        mutating func add(_ other: Self) {
            if !other.moves.isEmpty { moves.add(other.moves.elements(other.offset)) }
            if !other.deletes.isEmpty { deletes.add(other.deletes.elements(other.offset)) }
            if !other.reloads.isEmpty { reloads.add(other.reloads.elements(other.offset)) }
            isEmpty = isEmpty && other.isEmpty
        }

        mutating func move(_ index: Element) {
            moves.isEmpty ? moves = .init(index) : moves.add(index)
        }

        mutating func move(_ lower: Element, _ upper: Element) {
            moves.isEmpty ? moves = .init(lower, upper) : moves.add(lower, upper)
        }

        func apply(by listView: ListView) {
            if !deletes.isEmpty { Collection.delete(deletes.elements(offset), by: listView) }
            if !reloads.isEmpty { Collection.reload(reloads.elements(offset), by: listView) }
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
            all.elements(offset).reversed().forEach { $0.remove(from: &caches) }
        }

        func offseted(by offset: Collection.Element?) -> Self {
            var source = self
            source.offset = offset
            return source
        }

        var listDebugDescriptions: [String] {
            var descriptions = [String]()
            if !deletes.isEmpty { descriptions.append("D \(deletes.descriptions(with: offset))") }
            if !reloads.isEmpty { descriptions.append("U \(reloads.descriptions(with: offset))") }
            return descriptions
        }
    }
}

extension BatchUpdates {
    struct Target<Collection: UpdateIndexCollection>: IndexBatchUpdate {
        var offset: Mapping<Collection.Element>?
        var moves = Collection()
        var reloads = Collection()
        var inserts = Collection()
        var moveDict = [Element: Element]()
        var isEmpty = true
        var all: Collection {
            var all = Collection()
            if !moves.isEmpty { all.add(moves) }
            if !inserts.isEmpty { all.add(inserts) }
            if !reloads.isEmpty { all.add(reloads) }
            return all
        }

        mutating func move(_ index: Element, to newIndex: Element) {
            moves.isEmpty ? moves = .init(newIndex) : moves.add(newIndex)
            moveDict[newIndex] = index
            guard index != newIndex else { return }
            isEmpty = false
        }

        mutating func move(_ lower: Mapping<Element>, _ upper: Mapping<Element>) {
            moves.isEmpty
                ? moves = .init(lower.target, upper.target)
                : moves.add(lower.target, upper.target)
            let from = Collection(lower.source, upper.source).elements(nil)
            let to = Collection(lower.target, upper.target).elements(nil)
            zip(from, to).forEach { moveDict[$0.1] = $0.0 }
            guard lower != upper else { return }
            isEmpty = false
        }

        mutating func reload(_ newIndex: Element) {
            reloads.isEmpty ? reloads = .init(newIndex) : reloads.add(newIndex)
            isEmpty = false
        }

        mutating func reload(_ lower: Element, _ upper: Element) {
            reloads.isEmpty ? reloads = .init(lower, upper) : reloads.add(lower, upper)
            isEmpty = false
        }

        mutating func add(_ other: Self) {
            if !other.reloads.isEmpty { reloads.add(other.reloads.elements(other.offset?.target)) }
            if !other.inserts.isEmpty { inserts.add(other.inserts.elements(other.offset?.target)) }
            if !other.moves.isEmpty { moves.add(other.moves.elements(other.offset?.target)) }
            if !other.moveDict.isEmpty { other.enumerateMoves { moveDict[$0.target] = $0.source } }
            isEmpty = isEmpty && other.isEmpty
        }

        func enumerateMoves(_ closure: (Mapping<Element>) -> Void) {
            moves.elements(nil).forEach { rawTo in
                let rawFrom = moveDict[rawTo]!
                let move = offset.map { (rawFrom.offseted($0.source), rawTo.offseted($0.target)) }
                closure(move ?? (rawFrom, rawTo))
            }
        }

        func apply(by listView: ListView) {
            if !inserts.isEmpty { Collection.insert(inserts.elements(offset?.target), by: listView) }
            if !moves.isEmpty { enumerateMoves { Collection.move($0, by: listView) } }
        }

        func add<Cache>(
            from caches: inout ContiguousArray<ContiguousArray<Cache?>>,
            _ itemMoves: inout [IndexPath: Cache?],
            _ sectionMoves: inout [Int: ContiguousArray<Cache?>]
        ) {
            if moves.isEmpty { return }
            enumerateMoves { $0.target.add($0.source, from: &caches, &itemMoves, &sectionMoves) }
        }

        func apply<Cache>(
            by caches: inout ContiguousArray<ContiguousArray<Cache?>>,
            _ itemMoves: [IndexPath: Cache?],
            _ sectionMoves: [Int: ContiguousArray<Cache?>],
            countIn: (Int) -> Int
        ) {
            all.elements(offset?.target).forEach {
                $0.insert(to: &caches, itemMoves, sectionMoves, countIn: countIn)
            }
        }

        func offseted(by offset: Mapping<Collection.Element>?) -> Self {
            guard let offset = offset else { return self }
            var source = Self()
            if !moves.isEmpty { source.add(\.moves, moves.elements(offset.target)) }
            if !inserts.isEmpty { source.add(\.inserts, inserts.elements(offset.target)) }
            if !reloads.isEmpty { source.add(\.reloads, reloads.elements(offset.target)) }
            source.moveDict.reserveCapacity(moveDict.count)
            moveDict.forEach {
                source.moveDict[$0.key.offseted(offset.target)] = $0.value.offseted(offset.source)
            }
            return source
        }

        var listDebugDescriptions: [String] {
            var descriptions = [String]()
            if !inserts.isEmpty { descriptions.append("I \(inserts.descriptions(with: offset?.target))") }
            if !moves.isEmpty {
                var descs = [String]()
                enumerateMoves { descs.append("(\($0.source), \($0.target))") }
                descriptions.append("M \(descs.joined(separator: " "))")
            }
            return descriptions
        }
    }
}

extension BatchUpdates {
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
}

extension BatchUpdates {
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

extension BatchUpdates.Source {
    init(move index: Element) {
        moves = .init(index)
    }
}

extension BatchUpdates.Target {
    init(move index: Element, to newIndex: Element) {
        moves = .init(newIndex)
        moveDict[newIndex] = index
        guard index != newIndex else { return }
        isEmpty = false
    }
}

extension IndexBatchUpdate {
    mutating func add(_ path: WritableKeyPath<Self, Collection>, _ index: Element) {
        self[keyPath: path].isEmpty
            ? self[keyPath: path] = .init(index)
            : self[keyPath: path].add(index)
        isEmpty = false
    }

    mutating func add(_ path: WritableKeyPath<Self, Collection>, _ indices: Collection) {
        self[keyPath: path].isEmpty
            ? self[keyPath: path] = indices
            : self[keyPath: path].add(indices)
        isEmpty = false
    }

    mutating func add(_ path: WritableKeyPath<Self, Collection>, _ elements: Collection.Elements) {
        self[keyPath: path].isEmpty
            ? self[keyPath: path] = .init(elements)
            : self[keyPath: path].add(elements)
        isEmpty = false
    }

    mutating func add(_ path: WritableKeyPath<Self, Collection>, _ lower: Element, _ upper: Element) {
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
