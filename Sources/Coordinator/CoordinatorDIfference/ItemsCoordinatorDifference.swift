//
//  ItemsCoornatorDifference.swift
//  ListKit
//
//  Created by Frain on 2020/5/16.
//

import Foundation

final class ItemsCoordinatorDifference<Item>: CoordinatorDifference {
    typealias ValueElement = Element<Item, ItemRelatedCache>
    typealias Diffable = ListKit.ValueRelated<Item, ItemRelatedCache>
    
    let mapping: Mapping<ContiguousArray<Diffable>>
    let differ: Differ<Diffable>?
    
    var rangeRelplacable = false
    var keepSectionIfEmpty: Mapping<Bool> = (false, false)
    var extraCoordinatorChange: ((ContiguousArray<Diffable>) -> Void)?
    var updateSectionCount: ((Int?) -> Void)?
    var coordinatorChange: (() -> Void)?
    
    var changes: Mapping<ContiguousArray<ValueElement>> = ([], [])
    var uniques: Mapping<ContiguousArray<ValueElement>> = ([], [])
    
    var sourceSection = 0
    var needThirdUpdate = false
    
    var sourceIsEmpty: Bool { mapping.source.isEmpty && !keepSectionIfEmpty.source }
    var targetIsEmpty: Bool { mapping.target.isEmpty && !keepSectionIfEmpty.target }
    
    lazy var itemsCount = mapping.source.count
    lazy var sectionCount = sourceIsEmpty ? 0 : 1
    
    lazy var thirdItems = ContiguousArray<Diffable>()
    lazy var thirdUpdates = [IndexPath]()
    
    init(mapping: Mapping<ContiguousArray<Diffable>>, differ: Differ<Item>?) {
        self.mapping = mapping
        self.differ = differ.map { .init($0) { $0.value } }
        super.init()
    }
    
    override func prepareForGenerate() {
//        let reloadable = rangeRelplacable ? nil : false
//        (changes, uniques) = toChanges(mapping: mapping, differ: differ, moveAndRelod: reloadable)
    }
    
    override func inferringMoves(context: Context) {
        guard let id = differ?.identifier else { return }
        uniques.source.forEach {
            add(to: &context.uniqueChange, key: id($0.valueRelated), change: $0, isSource: true)
        }
        uniques.target.forEach {
            add(to: &context.uniqueChange, key: id($0.valueRelated), change: $0, isSource: false)
        }
        
//        applying(to: &context.uniqueChange, with: &uniques, id: id, equal: differ.areEquivalent)
    }
    
    override func generateUpdates() -> Updates? {
        generateUpdates(for: mapping)
    }
    
    override func generateListUpdates(itemSources: (Int, Bool)?) -> ListUpdates {
        guard let update = updates else { return [] }
        switch (update, itemSources) {
        case let (.batchUpdates(batchUpdates), _):
            return batchUpdates
        case (.insertAll, (0, false)?),
            (.insertAll, nil) where !keepSectionIfEmpty.source:
            let section = SectionUpdate(target: .init(insertions: .init(integer: 0)))
            return [(ListBatchUpdates(section: section), coordinatorChange)]
        case (.insertAll, _):
            let index = mapping.target.indices.map { IndexPath(item: $0) }
            let item = ItemUpdate(target: .init(insertions: index))
            return [(ListBatchUpdates(item: item), coordinatorChange)]
        case (.removeAll, (mapping.source.count, false)?),
             (.removeAll, nil) where !keepSectionIfEmpty.target:
            let section = SectionUpdate(source: .init(deletions: .init(integer: 0)))
            return [(ListBatchUpdates(section: section), coordinatorChange)]
        case (.removeAll, _):
            let index = mapping.source.indices.map { IndexPath(item: $0) }
            let item = ItemUpdate(source: .init(deletions: index))
            return [(ListBatchUpdates(item: item), coordinatorChange)]
        case (.reloadAll, _):
            return []
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
            guard case let (_, itemUpdate?) = generateSourceItemUpdate(
                order: .second,
                sectionOffset: sectionOffset,
                itemOffset: 0,
                isMoved: false
            ) else { return (sectionCount, nil) }
            return (sectionCount, .init(item: itemUpdate))
        case .third where !sourceIsEmpty && targetIsEmpty:
            return (1, .init(section: .init(deletions: .init(integer: sectionOffset))))
        default:
            return (sectionCount, nil)
        }
    }
    
    override func generateTargetSectionUpdate(
        order: Order,
        sectionOffset: Int = 0,
        isMoved: Bool = false
    ) -> (count: Int, update: TargetBatchUpdates?, change: (() -> Void)?) {
        switch order {
        case .first where sourceIsEmpty && !targetIsEmpty:
            sectionCount = 1
            let countChange = updateSectionCount.map { change in { change(1) } }
            let section = SectionTargetUpdate(insertions: .init(integer: sectionOffset))
            return (sectionCount, .init(section: section), countChange)
        case .first where !sourceIsEmpty && targetIsEmpty:
            var change = TargetBatchUpdates()
            sectionCount = 1
            let countChange = updateSectionCount.map { change in { change(1) } }
            if isMoved { change.section.moves.append((sourceSection, sectionOffset)) }
            return (sectionCount, change, countChange)
        case .first where isMoved && !sourceIsEmpty:
            return (1, .init(section: .init(moves: [(sourceSection, sectionOffset)])), nil)
        case .third where !sourceIsEmpty && targetIsEmpty:
            sectionCount = 0
            let countChange = updateSectionCount.map { change in { change(nil) } }
            return (0, .init(), countChange)
        case .second,
             .third where needThirdUpdate:
            guard case let (_, itemUpdate?, change) = generateTargetItemUpdate(
                order: order,
                sectionOffset: sectionOffset,
                itemOffset: 0,
                isMoved: false
            ) else { return (sectionCount, nil, nil) }
            return (sectionCount, .init(item: itemUpdate), change)
        default:
            return (sectionCount, nil, nil)
        }
    }
    
    override func generateSourceItemUpdate(
        order: Order,
        sectionOffset: Int = 0,
        itemOffset: Int = 0,
        isMoved: Bool = false
    ) -> (count: Int, update: ItemSourceUpdate?) {
        guard order == .second else { return (itemsCount, nil) }
        var update = ItemSourceUpdate()
        for element in changes.source {
            element.sectionOffset = sectionOffset
            element.itemOffset = itemOffset
            switch (element.state, element.associated) {
            case (.reload, .some) where isMoved:
                if rangeRelplacable {
                    needThirdUpdate = true
                } else {
                    update.deletions.append(element.indexPath)
                }
            case let (.change(moveAndRelod), .some) where moveAndRelod == true:
                needThirdUpdate = true
            case (.change, .none):
                update.deletions.append(element.indexPath)
            default:
                continue
            }
        }
        return (itemsCount, update)
    }
    
    override func generateTargetItemUpdate(
        order: Order,
        sectionOffset: Int = 0,
        itemOffset: Int = 0,
        isMoved: Bool = false
    ) -> (count: Int, update: ItemTargetUpdate?, change: (() -> Void)?) {
        switch order {
        case .second:
            var change: (() -> Void)?
            itemsCount = mapping.target.count
            var update = ItemTargetUpdate()
            for element in changes.target {
                element.sectionOffset = sectionOffset
                element.itemOffset = itemOffset
                switch (element.state, element.associated) {
                case let (.change(moveAndRelod), associaed?):
                    update.moves.append((associaed.indexPath, element.indexPath))
                    if moveAndRelod == true {
                        thirdUpdates.append(element.indexPath)
                        if needThirdUpdate { thirdItems.append(associaed.valueRelated) }
                    } else {
                        if needThirdUpdate { thirdItems.append(element.valueRelated) }
                        change = change + { element.related.updateFrom(associaed.related) }
                    }
                case let (.reload, associaed?):
                    switch (isMoved, rangeRelplacable) {
                    case (true, false):
                        update.insertions.append(element.indexPath)
                    case (true, true):
                        update.moves.append((associaed.indexPath, element.indexPath))
                        thirdUpdates.append(element.indexPath)
                        if needThirdUpdate { thirdItems.append(associaed.valueRelated) }
                    default:
                        update.updates.append(element.indexPath)
                        if needThirdUpdate { thirdItems.append(element.valueRelated) }
                    }
                case let (_, associaed?):
                    if isMoved { update.moves.append((associaed.indexPath, element.indexPath)) }
                    if needThirdUpdate { thirdItems.append(element.valueRelated) }
                    change = change + { element.related.updateFrom(associaed.related) }
                default:
                    update.insertions.append(element.indexPath)
                    if needThirdUpdate { thirdItems.append(element.valueRelated) }
                }
            }
            
            if needThirdUpdate {
                let extraChange = extraCoordinatorChange
                let items = thirdItems
                return (itemsCount, update, change + { extraChange?(items) })
            } else {
                return (itemsCount, update, change + coordinatorChange)
            }
        case .third where needThirdUpdate:
            var update = ItemTargetUpdate()
            update.updates = thirdUpdates
            return (itemsCount, update, coordinatorChange)
        default:
            return (0, nil, nil)
        }
    }
}
