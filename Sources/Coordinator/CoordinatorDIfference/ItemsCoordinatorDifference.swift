//
//  ItemsCoornatorDifference.swift
//  ListKit
//
//  Created by Frain on 2020/5/16.
//

import Foundation

final class ItemsCoordinatorDifference<Item>: CoordinatorDifference {
    typealias ValueElement = Element<Item, ItemRelatedCache>
    typealias Diffable = ListKit.Diffable<Item, ItemRelatedCache>
    
    let mapping: Mapping<[Diffable]>
    let differ: Differ<Diffable>
    
    var rangeRelplacable = false
    var internalCoordinatorChange: (([Diffable]) -> Void)?
    var coordinatorChange: (() -> Void)?
    
    var changes: Mapping<[ValueElement]> = ([], [])
    var uniqueChange: Mapping<[ValueElement]> = ([], [])
    
    var sourceSection = 0
    var targetSection = 0
    
    lazy var itemsCount = mapping.source.count
    
    lazy var needThirdUpdate = false
    lazy var thirdItems = [Diffable]()
    lazy var thirdUpdates = [IndexPath]()
    
    init(mapping: Mapping<[Diffable]>, differ: Differ<Item>) {
        self.mapping = mapping
        self.differ = .init(differ) { $0.value }
        super.init()
    }
    
    override func prepareForGenerate() {
        let moveAndRelod = rangeRelplacable ? nil : false
        
        switch (mapping.source.isEmpty, mapping.target.isEmpty) {
        case (false, true):
            (changes.source, uniqueChange.source) = toChanges(
                values: mapping.source,
                differ: differ,
                isSource: true,
                moveAndRelod: moveAndRelod
            )
        case (true, false):
            (changes.target, uniqueChange.target) = toChanges(
                values: mapping.target,
                differ: differ,
                isSource: false,
                moveAndRelod: moveAndRelod
            )
        case (false, false):
            (changes, uniqueChange) = toChanges(
                mapping: mapping,
                differ: differ,
                moveAndRelod: moveAndRelod
            )
        case (true, true):
            return
        }
    }
    
    override func inferringMoves(context: Context) {
        guard let id = differ.identifier else { return }
        uniqueChange.source.forEach {
            add(to: &context.uniqueChange, key: id($0.asTuple), change: $0, isSource: true)
        }
        uniqueChange.target.forEach {
            add(to: &context.uniqueChange, key: id($0.asTuple), change: $0, isSource: false)
        }
        
        applying(to: &context.uniqueChange, with: &uniqueChange, id: id, differ: differ)
    }
    
    override func generateUpdates() -> ListUpdates {
        prepareForGenerate()
        return [Order.second, Order.third].compactMap { order in
            let source = generateSourceItemUpdate(order: order)
            let target = generateTargetItemUpdate(order: order)
            guard source.update != nil || target.update != nil else { return nil }
            var itemUpdate = ItemUpdate()
            source.update.map { itemUpdate.source = $0 }
            target.update.map { itemUpdate.target = $0 }
            return (itemUpdate, target.change)
        }
    }
    
    override func generateSourceSectionUpdate(
        order: Order,
        sectionOffset: Int = 0,
        isMoved: Bool = false
    ) -> (count: Int, update: SourceBatchUpdates?) {
        sourceSection = sectionOffset
        guard order == .second, case let (_, itemUpdate?) = generateSourceItemUpdate(
            order: .second,
            sectionOffset: sectionOffset,
            itemOffset: 0,
            isMoved: false
        ) else { return (1, nil) }
        return (1, .init(item: itemUpdate))
    }
    
    override func generateTargetSectionUpdate(
        order: Order,
        sectionOffset: Int = 0,
        isMoved: Bool = false
    ) -> (count: Int, update: TargetBatchUpdates?, change: (() -> Void)?) {
        targetSection = sectionOffset
        switch order {
        case .first where isMoved:
            return (1, .init(section: .init(moves: [(sourceSection, targetSection)])), nil)
        case .second, .third:
            guard case let (_, itemUpdate?, change) = generateTargetItemUpdate(
                order: order,
                sectionOffset: sectionOffset,
                itemOffset: 0,
                isMoved: false
            ) else { fallthrough }
            return (1, .init(item: itemUpdate), change)
        default:
            return (1, nil, nil)
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
            case (.reload, .some):
                if isMoved && !rangeRelplacable {
                    update.deletions.append(element.indexPath)
                } else {
                    needThirdUpdate = true
                }
            case let (.change, associaed?):
                if associaed.state == .change(moveAndRelod: true) { needThirdUpdate = true }
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
            itemsCount = mapping.target.count
            var update = ItemTargetUpdate()
            for element in changes.target {
                element.sectionOffset = sectionOffset
                element.itemOffset = itemOffset
                switch (element.state, element.associated) {
                case let (.change(moveAndRelod), associaed?):
                    if moveAndRelod == true {
                        update.moves.append((associaed.indexPath, element.indexPath))
                        thirdUpdates.append(element.indexPath)
                        if needThirdUpdate { thirdItems.append(associaed.asTuple) }
                    } else {
                        update.moves.append((associaed.indexPath, element.indexPath))
                        if needThirdUpdate { thirdItems.append(element.asTuple) }
                    }
                case let (.reload, associaed?):
                    switch (isMoved, rangeRelplacable) {
                    case (true, false):
                        update.insertions.append(element.indexPath)
                    case (true, true):
                        update.moves.append((associaed.indexPath, element.indexPath))
                        thirdUpdates.append(element.indexPath)
                        if needThirdUpdate { thirdItems.append(associaed.asTuple) }
                    case (_, _):
                        update.updates.append(element.indexPath)
                        if needThirdUpdate { thirdItems.append(element.asTuple) }
                    }
                case let (_, associaed?):
                    if isMoved { update.moves.append((associaed.indexPath, element.indexPath)) }
                    if needThirdUpdate { thirdItems.append(element.asTuple) }
                default:
                    update.insertions.append(element.indexPath)
                    if needThirdUpdate { thirdItems.append(element.asTuple) }
                }
            }
            
            if needThirdUpdate {
                let change = internalCoordinatorChange
                let items = thirdItems
                return (itemsCount, update, { change?(items) })
            } else {
                return (itemsCount, update, coordinatorChange)
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
