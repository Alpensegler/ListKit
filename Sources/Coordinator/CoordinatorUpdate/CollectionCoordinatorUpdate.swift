//
//  CollectionCoordinatorUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/7/5.
//

import Foundation

class CollectionCoordinatorUpdate<SourceBase, Source, Value>: CoordinatorUpdate<SourceBase>
where
    SourceBase: DataSource,
    SourceBase.SourceBase == SourceBase,
    Source: Collection
{
    typealias Index = Source.Index
    typealias Element = Source.Element
    typealias Values = Mapping<ContiguousArray<Value>>
    typealias ChangeValue = (element: Element?, related: Int?)
    
    typealias Indices = ContiguousArray<Int>
    
    var values: Values
    var keepSectionIfEmpty = (source: false, target: false)
    lazy var updatedValues = values.target
    
    var isSectioned = false
    var needExtraUpdate = UpdateContextCache(value: false)
    
    var appendValues = [Element]()
    var insertIndices = IndexSet()
    var deleteIndices = IndexSet()
    var updateIndices = IndexSet()
    
    var insertDict = [Int: ChangeValue]()
    var deleteDict = [Int: ChangeValue]()
    var updateDict = [Int: Element]()
    
    var sourceCount: Int { values.source.count }
    var targetCount: Int { values.target.count }
    
    var sourceIsEmpty: Bool { values.source.isEmpty }
    var targetIsEmpty: Bool { values.target.isEmpty }
    
    var differ: Differ<SourceBase.Item>! { update?.diff }
    var diffable: Bool { differ?.isNone == false }
    var rangeReplacable: Bool { false }
    
    init(
        _ coordinator: ListCoordinator<SourceBase>? = nil,
        update: Update<SourceBase>,
        values: Values,
        sources: Sources
    ) {
        self.values = values
        super.init(coordinator: coordinator, update: update, sources: sources)
    }
    
    func toValue(_ element: Element) -> Value { fatalError("should be implemented by subclass") }
    
    override func configChangeType() -> UpdateChangeType {
        isSectioned ? configChangeTypeForSections() : configChangeTypeForItems()
    }
    
    override func generateListUpdates() -> BatchUpdates? {
        isSectioned ? generateListUpdatesForSections() : generateListUpdatesForItems()
    }
}

extension CollectionCoordinatorUpdate {
    var sourceHasSection: Bool { !sourceIsEmpty || keepSectionIfEmpty.source }
    var targetHasSection: Bool { !targetIsEmpty || keepSectionIfEmpty.target }
    
    var sourceSectionCount: Int { isSectioned ? sourceCount : sourceHasSection ? 1 : 0 }
    var targetSectionCount: Int { isSectioned ? targetCount : targetHasSection ? 1 : 0 }
    
    func configChangeTypeForItems() -> UpdateChangeType {
        switch (sourceIsEmpty, targetIsEmpty, keepSectionIfEmpty) {
        case (true, true, (false, true)): return .insert(.section)
        case (true, true, (true, false)): return .remove(.section)
        case (true, true, _): return .none
        case (true, false, _): return .insert(keepSectionIfEmpty.source ? .items : .itemsAndSection)
        case (false, true, _): return .remove(keepSectionIfEmpty.target ? .items : .itemsAndSection)
        case (false, false, _): return diffable ? .batchUpdates : .reload
        }
    }
    
    func configChangeTypeForSections() -> UpdateChangeType {
        switch (sourceIsEmpty, targetIsEmpty) {
        case (true, true): return .none
        case (true, false): return .insert()
        case (false, true): return .remove()
        case (false, false): return diffable ? .batchUpdates : .reload
        }
    }
    
    func generateListUpdatesForItems() -> BatchUpdates? {
        switch changeType {
        case .insert(.section), .insert(.itemsAndSection):
            return .init(target: BatchUpdates.SectionTarget(\.inserts, 0), finalChange)
        case .insert(.items):
            let indices = [IndexPath](IndexPath(item: 0), IndexPath(item: targetCount))
            return .init(target: BatchUpdates.ItemTarget(\.inserts, indices), finalChange)
        case .remove(.section), .remove(.itemsAndSection):
            return .init(source: BatchUpdates.SectionSource(\.deletes, 0), finalChange)
        case .remove(.items):
            let indices = [IndexPath](IndexPath(item: 0), IndexPath(item: sourceCount))
            return .init(source: BatchUpdates.ItemSource(\.deletes, indices), finalChange)
        case .batchUpdates:
            return listUpdatesForItems()
        case .reload:
            return .reload(change: finalChange)
        case .none:
            return .none
        }
    }
    
    func generateListUpdatesForSections() -> BatchUpdates? {
        switch changeType {
        case .insert:
            return .init(target: BatchUpdates.SectionTarget(\.inserts, 0, targetCount), finalChange)
        case .remove:
            return .init(source: BatchUpdates.SectionSource(\.deletes, 0, sourceCount), finalChange)
        case .batchUpdates:
            return listUpdatesForSections()
        case .reload:
            return .reload(change: finalChange)
        case .none:
            return .none
        }
    }
}

extension CollectionCoordinatorUpdate
where SourceBase.Source: RangeReplaceableCollection, SourceBase.Source == Source {
    func append(_ element: Element) {
        appendValues.append(element)
        updatedSource?.append(element)
        updatedValues.append(toValue(element))
    }
    
    func append<S: Sequence>(contentsOf elements: S) where Element == S.Element {
        appendValues.append(contentsOf: elements)
        updatedSource?.append(contentsOf: elements)
        updatedValues.append(contentsOf: elements.map(toValue))
    }
    
    func insert(_ element: Element, at index: Index) {
        guard let intIndex = intIndex(from: index) else { return }
        updatedSource?.insert(element, at: index)
        updatedValues.insert(toValue(element), at: intIndex)
        insertIndices.insert(intIndex)
        insertDict[intIndex] = (element, nil)
    }
    
    func insert<C: Collection>(contentsOf elements: C, at index: Index) where Element == C.Element {
        guard var intIndex = intIndex(from: index) else { return }
        updatedSource?.insert(contentsOf: elements, at: index)
        updatedValues.insert(contentsOf: elements.map(toValue), at: intIndex)
        insertIndices.insert(integersIn: intIndex..<intIndex + elements.count)
        for element in elements {
            insertDict[intIndex] = (element, nil)
            intIndex += 1
        }
    }
    
    func remove(at index: Index) {
        guard let intIndex = intIndex(from: index) else { return }
        deleteIndices.insert(intIndex)
        updatedSource?.remove(at: index)
        updatedValues.remove(at: intIndex)
    }
    
    func update(_ element: Element, at index: Index) {
        guard let source = updatedSource, let intIndex = intIndex(from: index) else { return }
        let indexAfter = source.index(after: index)
        updatedSource?.replaceSubrange(index..<indexAfter, with: CollectionOfOne(element))
        updatedValues[intIndex] = toValue(element)
        updateIndices.insert(intIndex)
        updateDict[intIndex] = element
    }
    
    func move(at index: Index, to newIndex: Index) {
        guard let element = sources.source?[index],
              let source = updatedSource,
              let intIndex = intIndex(from: index),
              let newIntIndex = self.intIndex(from: newIndex)
        else { return }
        let indexAfter = source.index(after: newIndex)
        updatedSource?.replaceSubrange(newIndex..<indexAfter, with: CollectionOfOne(element))
        updatedValues[newIntIndex] = toValue(element)
        insertIndices.insert(newIntIndex)
        deleteIndices.insert(intIndex)
        insertDict[newIntIndex] = (nil, intIndex)
        deleteDict[intIndex] = (nil, newIntIndex)
    }
    
    func intIndex(from index: Index) -> Int? {
        guard let source = updatedSource else { return nil }
        return source.distance(from: source.startIndex, to: index)
    }
}
