//
//  SourcesCoordinatorDifference.swift
//  ListKit
//
//  Created by Frain on 2020/5/15.
//

import Foundation

final class SourcesCoordinatorDifference<Value, Item>: CoordinatorDifference {
    typealias MapValue = (value: Value, related: Coordinator)
    final class DataSourceElement: Element<Value, Coordinator> {
        var difference: CoordinatorDifference?
    }
    
    let mapping: Mapping<[MapValue]>
    let differ: Differ<MapValue>
    let itemDiffer: Differ<Item>?
    
    var isSectioned = false
    var changes: Mapping<[DataSourceElement]> = ([], [])
    var uniqueChanges: Mapping<[DataSourceElement]> = ([], [])
    
    init(mapping: Mapping<[MapValue]>, offsets: Mapping<[Int]>, differ: Differ<MapValue>, itemDiffer: Differ<Item>?) {
        self.mapping = mapping
        self.differ = differ
        self.itemDiffer = itemDiffer
        super.init()
    }
    
    override func prepareForGenerate() {
        (changes, uniqueChanges) = toChanges(mapping: mapping, differ: differ)
    }
    
    override func inferringMoves(context: CoordinatorDifference.Context) {
        
    }
}
