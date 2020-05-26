//
//  SectionsCoordinatorDifference.swift
//  ListKit
//
//  Created by Frain on 2020/5/19.
//

import Foundation

final class SectionsCoordinatorDifference<Item>: CoordinatorDifference {
    typealias ValueElement = Element<Item, ItemRelatedCache>
    typealias Diffable = ListKit.Diffable<Item, ItemRelatedCache>
    
    class DifferenceMapping {
        let difference: ItemsCoordinatorDifference<Item>
        var values: [Diffable]
        
        init(_ mapping: Mapping<[Diffable]>, differ: Differ<Item>, rangeRelplacable: Bool) {
            values = mapping.source
            difference = .init(mapping: mapping, differ: differ)
            difference.coordinatorChange = { [unowned self] in self.values = mapping.target }
            difference.extraCoordinatorChange = { [unowned self] in self.values = $0 }
            difference.keepSectionIfEmpty = (true, true)
            difference.rangeRelplacable = rangeRelplacable
            difference.prepareForGenerate()
        }
    }
    
    enum Rest {
        case differences([ItemsCoordinatorDifference<Item>], isSource: Bool)
        case count(count: Int, isSource: Bool)
        case none
        
        var differencesIsSource: Bool? {
            guard case let .differences(_, isSource) = self else { return nil }
            return isSource
        }
    }
    
    let mapping: Mapping<[[Diffable]]>
    let differ: Differ<Item>
    
    var rangeRelplacable = false
    var extraCoordinatorChange: (([[Diffable]]) -> Void)?
    var coordinatorChange: (() -> Void)?
    
    var differenceMapping = [DifferenceMapping]()
    var rests = Rest.none
    var sectionOffset: Mapping<Int> = (0, 0)
    
    var sourceSection = 0
    var targetSection = 0
    
    var needThirdUpdate = false
    var needInternalUpdate = false
    
    lazy var sectionCount = mapping.source.count
    
    var extraValues: [[Diffable]] {
        var values = differenceMapping.map { $0.values }
        if case let .differences(rests, _) = rests {
            values += rests.indices.map { _ in [] }
        }
        return values
    }
    
    init(mapping: Mapping<[[Diffable]]>, differ: Differ<Item>) {
        self.mapping = mapping
        self.differ = differ
        super.init()
    }
    
    override func prepareForGenerate() {
        differenceMapping = zip(mapping.source, mapping.target).map {
            DifferenceMapping(($0.0, $0.1), differ: differ, rangeRelplacable: rangeRelplacable)
        }
        let diff = mapping.source.count - mapping.target.count
        guard diff != 0 else { return }
        let isSource = diff > 0
        if rangeRelplacable {
            let values = isSource ? mapping.source : mapping.target
            let subvalues = values[values.count - abs(diff)..<values.count]
            let differences = subvalues.map { values -> ItemsCoordinatorDifference<Item> in
                let mapping = isSource ? (values, []) : ([], values)
                let difference = ItemsCoordinatorDifference(mapping: mapping, differ: differ)
                difference.rangeRelplacable = true
                difference.prepareForGenerate()
                difference.keepSectionIfEmpty = (true, true)
                return difference
            }
            rests = .differences(differences, isSource: isSource)
        } else {
            rests = .count(count: abs(diff), isSource: isSource)
        }
    }
    
    override func inferringMoves(context: Context) {
        guard differ.identifier != nil else { return }
        differenceMapping.forEach { $0.difference.inferringMoves(context: context) }
        guard case let .differences(differences, _) = rests else { return }
        differences.forEach { $0.inferringMoves(context: context) }
    }
    
    override func generateUpdates(_ change: (() -> Void)?) -> ListUpdates? {
        switch (mapping.source.isEmpty, mapping.target.isEmpty) {
        case (false, false):
            prepareForGenerate()
            inferringMoves(context: .init())
            let batchUpdates: ListBatchUpdates = Order.allCases.compactMap { order in
                let source = generateSourceSectionUpdate(order: order)
                let target = generateTargetSectionUpdate(order: order)
                guard source.update != nil || target.update != nil else { return nil }
                var batchUpdate = BatchUpdates<SectionUpdate, ItemUpdate>()
                source.update.map {
                    batchUpdate.section.source = $0.section
                    batchUpdate.item.source = $0.item
                }
                target.update.map {
                    batchUpdate.section.target = $0.section
                    batchUpdate.item.target = $0.item
                }
                return (batchUpdate, target.change + change)
            }
            return batchUpdates.isEmpty ? nil : .batchUpdates(batchUpdates)
        case (true, false):
            return .changeAll(.insert, coordinatorChange + change)
        case (false, true):
            return .changeAll(.remove, coordinatorChange + change)
        case (true, true):
            return nil
        }
    }
    
    override func generateSourceSectionUpdate(
        order: Order,
        sectionOffset: Int = 0,
        isMoved: Bool = false
    ) -> (count: Int, update: SourceBatchUpdates?) {
        sourceSection = sectionOffset
        switch order {
        case .second:
            var updates = SourceBatchUpdates()
            var differences = differenceMapping.map { $0.difference }
            switch rests {
            case let .count(count, true):
                let sourceCount = mapping.source.count
                let range = sectionOffset + sourceCount - count..<sectionOffset + sourceCount
                updates.section = .init(deletions: .init(integersIn: range))
            case let .differences(rests, true):
                differences += rests
            default:
                break
            }
            
            for (offset, difference) in differences.enumerated() {
                defer { needThirdUpdate = needThirdUpdate || difference.needThirdUpdate }
                guard case let (_, update?) = difference.generateSourceItemUpdate(
                    order: .second,
                    sectionOffset: sectionOffset + offset,
                    itemOffset: 0,
                    isMoved: false
                ) else { continue }
                updates.item.add(other: update)
            }
            
            return (sectionCount, updates)
        case .third:
            guard case let .differences(difference, true) = rests else { fallthrough }
            let sourceCount = mapping.source.count
            let range = sectionOffset + sourceCount - difference.count..<sectionOffset + sourceCount
            return (sectionCount, .init(section: .init(deletions: .init(integersIn: range))))
        default:
            return (sectionCount, nil)
        }
    }
    
    override func generateTargetSectionUpdate(
        order: Order,
        sectionOffset: Int = 0,
        isMoved: Bool = false
    ) -> (count: Int, update: TargetBatchUpdates?, change: (() -> Void)?) {
        targetSection = sectionOffset
        switch order {
        case .first:
            if !isMoved, rests.differencesIsSource != false { return (sectionCount, nil, nil) }
            var update = SectionTargetUpdate()
            var change: (() -> Void)?
            if isMoved {
                update.moves = (0..<sectionCount).map { ($0 + sourceSection, $0 + sectionOffset) }
            }
            if case let .differences(difference, false) = rests {
                sectionCount = mapping.target.count
                let start = sectionOffset + sectionCount - difference.count
                let end = sectionOffset + sectionCount
                update.insertions = .init(integersIn: start..<end)
                var source = mapping.source
                source.append(contentsOf: (start..<end).map { _ in [] })
                change = change + extraCoordinatorChange.map { change in { change(source) } }
            }
            return (sectionOffset, .init(section: update), change)
        case .second:
            var updates = TargetBatchUpdates()
            var change: (() -> Void)?
            var differences = differenceMapping.map { $0.difference }
            needInternalUpdate = needThirdUpdate
            switch rests {
            case let .count(count, false):
                let targetCount = mapping.target.count
                let range = sectionOffset + targetCount - count..<sectionOffset + targetCount
                updates.section = .init(insertions: .init(integersIn: range))
            case let .differences(rests, false):
                differences += rests
            case .differences(_, true):
                needInternalUpdate = true
            default:
                break
            }
            
            for (offset, difference) in differences.enumerated() {
                guard case let (_, update?, itemChange) = difference.generateTargetItemUpdate(
                    order: .second,
                    sectionOffset: sectionOffset + offset,
                    itemOffset: 0,
                    isMoved: false
                ) else { continue }
                updates.item.add(other: update)
                if needInternalUpdate { change = change + itemChange }
            }
            
            change = needInternalUpdate
                ? change + extraCoordinatorChange.map { change in { change(self.extraValues) } }
                : coordinatorChange
            
            return (sectionCount, updates, change)
        case .third:
            sectionCount = mapping.target.count
            if !needInternalUpdate { return (sectionCount, nil, coordinatorChange) }
            var updates = TargetBatchUpdates()
            if needThirdUpdate {
                for difference in differenceMapping.lazy.compactMap({ $0.difference }) {
                    guard case let (_, update?, _) = difference.generateTargetItemUpdate(
                        order: .third,
                        sectionOffset: sectionOffset,
                        itemOffset: 0,
                        isMoved: false
                    ) else { continue }
                    updates.item.add(other: update)
                }
            }
            
            return (sectionCount, updates, coordinatorChange)
        }
    }
}
