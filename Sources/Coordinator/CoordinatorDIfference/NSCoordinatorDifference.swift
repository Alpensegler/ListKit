//
//  NSCoordinatorDifference.swift
//  ListKit
//
//  Created by Frain on 2020/6/1.
//

import Foundation

final class NSCoordinatorDifference: CoordinatorDifference {
    var coordinatorChange: (() -> Void)?
    var reload = true
    var multipleSection = true
    var keepSectionIfEmpty: Mapping<Bool> = (false, false)
    
    let mapping: Mapping<[Int]>
    
    var sourceSection = 0
    
    var hasMultiSetcion: Bool { mapping.source.count > 1 || mapping.target.count > 1 }
    var sourceIsEmpty: Bool { hasMultiSetcion ? mapping.source.isEmpty : sourceItemsIsEmpty }
    var targetIsEmpty: Bool { hasMultiSetcion ? mapping.target.isEmpty : targetItemsIsEmpty }
    
    var sourceItemsCount: Int { mapping.source.first ?? 0 }
    var targetItemsCount: Int { mapping.target.first ?? 0 }
    
    var sourceItemsIsEmpty: Bool { sourceItemsCount == 0 }
    var targetItemsIsEmpty: Bool { targetItemsCount == 0 }
    
    init(mapping: Mapping<[Int]>) {
        self.mapping = mapping
        super.init()
    }
    
    override func generateUpdates() -> Updates? {
        generateUpdates(for: (sourceIsEmpty, targetIsEmpty), reloadIfNeeded: reload)
    }
    
    override func generateSourceSectionUpdate(
        order: Order,
        sectionOffset: Int = 0,
        isMoved: Bool = false
    ) -> (count: Int, update: SourceBatchUpdates?) {
        sourceSection = sectionOffset
        guard order == .first else { return (mapping.target.count, nil) }
        if (reload && isMoved) || (!sourceIsEmpty && targetIsEmpty) {
            let set = IndexSet(integersIn: sectionOffset..<sectionOffset + mapping.source.count)
            return (mapping.source.count, .init(section: .init(deletions: set)))
        }
        var update = SourceBatchUpdates()
        
        let from = mapping.source.count
        let to = mapping.target.count
        let diff = from - to
        if diff > 0 {
            let range = sectionOffset + from - diff..<sectionOffset + from
            update.section.deletions.insert(integersIn: range)
        }
        return (mapping.source.count, update)
    }
    
    override func generateTargetSectionUpdate(
        order: Order,
        sectionOffset: Int = 0,
        isMoved: Bool = false
    ) -> (count: Int, update: TargetBatchUpdates?, change: (() -> Void)?) {
        guard order == .first else { return (mapping.target.count, nil, nil) }
        if (reload && isMoved) || (sourceIsEmpty && !targetIsEmpty) {
            let set = IndexSet(integersIn: sectionOffset..<sectionOffset + mapping.target.count)
            return (mapping.target.count, .init(section: .init(insertions: set)), coordinatorChange)
        }
        
        var update = TargetBatchUpdates()
        let from = mapping.source.count
        let to = mapping.target.count
        let diff = from - to
        let minValue = min(to, from)
        if minValue > 0, reload {
            update.section.updates.insert(integersIn: sectionOffset..<sectionOffset + minValue)
        }
        if minValue > 0, isMoved {
            update.section.moves = (0..<minValue).map { (sourceSection + $0, sectionOffset + $0) }
        }
        if diff > 0 {
            let range = sectionOffset + to - diff..<sectionOffset + to
            update.section.insertions.insert(integersIn: range)
        }
        return (mapping.target.count, update, coordinatorChange)
    }
    
//    override func generateSourceItemUpdate(
//        order: Order,
//        sectionOffset: Int = 0,
//        itemOffset: Int = 0,
//        isMoved: Bool = false
//    ) -> (count: Int, update: ItemSourceUpdate?) {
////        guard order == .second else { return (order == .first ? mapping.) }
//    }

//    override func generateTargetItemUpdate(
//        order: Order,
//        sectionOffset: Int = 0,
//        itemOffset: Int = 0,
//        isMoved: Bool = false
//    ) -> (count: Int, update: ItemTargetUpdate?, change: (() -> Void)? {
//
//    }
}
