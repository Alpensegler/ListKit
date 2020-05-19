//
//  SectionsCoordinatorDifference.swift
//  ListKit
//
//  Created by Frain on 2020/5/19.
//

import Foundation

final class SectionsCoordinatorDifference<Item>: CoordinatorDifference {
    typealias ValueElement = Element<Item, ItemRelatedCache>
    typealias MapValue = (value: Item, related: ItemRelatedCache)
    
    class DifferenceMapping {
        let difference: ItemsCoordinatorDifference<Item>
        var values: [MapValue]
        
        init(_ mapping: Mapping<[MapValue]>, differ: Differ<Item>, rangeRelplacable: Bool) {
            values = mapping.source
            difference = .init(mapping: mapping, differ: differ)
            difference.coordinatorChange = { self.values = mapping.source }
            difference.internalCoordinatorChange = { self.values = $0 }
            difference.rangeRelplacable = rangeRelplacable
            difference.prepareForGenerate()
        }
    }
    
    let mapping: Mapping<[[MapValue]]>
    let differ: Differ<Item>
    
    var rangeRelplacable = false
    var internalCoordinatorChange: (([[MapValue]]) -> Void)?
    var coordinatorBatchChange: ((Int, Bool) -> Void)?
    var coordinatorChange: (() -> Void)?
    
    var differenceMapping = [DifferenceMapping]()
    var rests: (count: Int, isSource: Bool)?
    var sectionOffset: Mapping<Int> = (0, 0)
    
    var valuesFromDifferenceMapping: [[MapValue]] {
        differenceMapping.map { $0.values }
    }
    
    init(mapping: Mapping<[[MapValue]]>, differ: Differ<Item>) {
        self.mapping = mapping
        self.differ = differ
        super.init()
    }
    
    override func prepareForGenerate() {
        let diff = mapping.source.count - mapping.target.count
        if diff != 0 { rests = (abs(diff), diff > 0) }
        differenceMapping = zip(mapping.source, mapping.target).map {
            DifferenceMapping(($0.0, $0.1), differ: differ, rangeRelplacable: rangeRelplacable)
        }
    }
    
    override func inferringMoves(context: Context) {
        guard differ.identifier != nil else { return }
        differenceMapping.forEach { $0.difference.inferringMoves(context: context) }
    }
    
    override func generateUpdate(isSectioned: Bool, isMoved: Bool) -> ListUpdate {
        var listUpdate = ListUpdate()
        differenceMapping.enumerated().forEach { arg in
            let source = sectionOffset.source + arg.offset
            let target = sectionOffset.target + arg.offset
            arg.element.difference.addingSection(offset: (source, target))
        }
        
        for difference in differenceMapping {
            let update = difference.difference.generateUpdate(isSectioned: true, isMoved: isMoved)
            listUpdate.adding(other: update)
        }
        
        if let (count, isSource) = rests {
            if isSource {
                let range = mapping.source.count - count..<mapping.source.count
                listUpdate.first.section.deletions = .init(range)
            } else {
                let range = mapping.target.count - count..<mapping.target.count
                listUpdate.first.section.insertions = .init(range)
            }
            
            let batchChange = coordinatorBatchChange
            listUpdate.first.adding { batchChange?(count, isSource) }
        }
        
        switch (listUpdate.second.isEmpty, listUpdate.third.isEmpty) {
        case (true, _):
            break
        case (false, true):
            listUpdate.second.adding(otherChange: coordinatorChange)
        case (false, false):
            let change = internalCoordinatorChange
            listUpdate.second.adding { change?(self.valuesFromDifferenceMapping) }
            listUpdate.third.adding(otherChange: coordinatorChange)
        }
        
        return listUpdate
    }
    
    override func generateUpdate() -> ListUpdate {
        prepareForGenerate()
        inferringMoves(context: .init())
        return generateUpdate(isSectioned: true, isMoved: false)
    }
}
