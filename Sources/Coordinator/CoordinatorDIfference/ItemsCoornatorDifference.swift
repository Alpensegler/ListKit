//
//  ItemsCoornatorDifference.swift
//  ListKit
//
//  Created by Frain on 2020/5/16.
//

import Foundation

final class ItemsCoornatorDifference<Item>: CoordinatorDifference {
    typealias ValueElement = Element<Item, ItemRelatedCache>
    typealias MapValue = (value: Item, related: ItemRelatedCache)
    
    let mapping: Mapping<[MapValue]>
    let differ: Differ<MapValue>
    
    var rangeRelplacable = false
    var internalCoordinatorChange: (([MapValue]) -> Void)?
    var coordinatorChange: (() -> Void)?
    
    var changes: Mapping<[ValueElement]> = ([], [])
    var uniqueChange: Mapping<[ValueElement]> = ([], [])
    
    init(mapping: Mapping<[MapValue]>, differ: Differ<Item>) {
        self.mapping = mapping
        self.differ = .init(differ) { $0.value }
        super.init()
    }
    
    override func prepareForGenerate() {
        let bool = rangeRelplacable ? nil : false
        (changes, uniqueChange) = toChanges(mapping: mapping, differ: differ, moveAndRelod: bool)
    }
    
    override func prepareForGenerate(context: Context) {
        prepareForGenerate()
        guard let id = differ.identifier else { return }
        uniqueChange.source.forEach {
            add(to: &context.uniqueChange, key: id($0.asTuple), change: $0, isSource: true)
        }
        uniqueChange.target.forEach {
            add(to: &context.uniqueChange, key: id($0.asTuple), change: $0, isSource: false)
        }
        
        applying(to: &context.uniqueChange, with: &uniqueChange, id: id, differ: differ)
    }
    
    override func generateUpdate(isSectioned: Bool, isMoved: Bool) -> ListUpdate {
        let moveSection = isMoved && isSectioned
        let moveItem = isMoved && !isSectioned
        
        var listUpdate = ListUpdate()
        var completions = [() -> Void]()
        
        var mapping = [MapValue]()
        
        var firstUpdate = BatchUpdate.Item()
        var secondUpdate = BatchUpdate.Item()
        
        if moveSection {
            var update = BatchUpdate.Section()
            update.deletions.append(0)
            update.insertions.append(0)
            listUpdate.batches.append(.init(section: update))
        }
        
        func addToUpdate(arg: (Int, Element<Item, ItemRelatedCache>), isSource: Bool) {
            let (item, element) = arg
            let index = IndexPath(item: item)
            switch (element.state, element.associated) {
            case let (.change(moveAndRelod), associaed?):
                if isSource { return }
                if moveAndRelod == true {
                    firstUpdate.moves.append((IndexPath(item: associaed.index), index))
                    secondUpdate.updates.append(index)
                    mapping.append(associaed.asTuple)
                } else {
                    firstUpdate.moves.append((IndexPath(item: associaed.index), index))
                    mapping.append(element.asTuple)
                }
            case let (.reload, associaed?):
                switch (moveItem, rangeRelplacable, isSource) {
                case (true, false, true):
                    firstUpdate.deletions.append(index)
                case (true, false, false):
                    firstUpdate.insertions.append(index)
                    mapping.append(element.asTuple)
                case (true, true, false):
                    firstUpdate.moves.append((IndexPath(item: associaed.index), index))
                    secondUpdate.updates.append(index)
                    mapping.append(associaed.asTuple)
                case (_, _, false):
                    firstUpdate.updates.append(index)
                    mapping.append(element.asTuple)
                default:
                    return
                }
            case let (_, associaed?):
                if isSource { return }
                if moveItem {
                    firstUpdate.moves.append((IndexPath(item: associaed.index), index))
                }
                mapping.append(element.asTuple)
            default:
                if isSource {
                    firstUpdate.deletions.append(index)
                } else {
                    firstUpdate.insertions.append(index)
                    mapping.append(element.asTuple)
                }
            }
        }
        
        changes.source.enumerated().forEach { addToUpdate(arg: $0, isSource: true) }
        changes.target.enumerated().forEach { addToUpdate(arg: $0, isSource: false) }
        
        switch (firstUpdate.isEmpty, secondUpdate.isEmpty) {
        case (true, _):
            break
        case (false, true):
            listUpdate.batches.append(.init(item: firstUpdate, change: coordinatorChange))
        case (false, false):
            let change = internalCoordinatorChange
            listUpdate.batches.append(.init(item: firstUpdate) { change?(mapping) })
            listUpdate.batches.append(.init(item: secondUpdate, change: coordinatorChange))
        }
        
        return listUpdate
    }
}
