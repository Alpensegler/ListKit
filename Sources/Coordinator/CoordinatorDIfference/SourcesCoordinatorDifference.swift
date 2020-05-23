//
//  SourcesCoordinatorDifference.swift
//  ListKit
//
//  Created by Frain on 2020/5/15.
//

import Foundation

final class SourcesCoordinatorDifference<Element: DataSource>: CoordinatorDifference {
    typealias Coordinator = ListCoordinator<Element.SourceBase>
    typealias Value = SourcesSubelement<Element>
    typealias MapValue = (value: Value, related: Coordinator)
    typealias Item = Element.SourceBase.Item
    
    final class DataSourceElement: CoordinatorDifference.Element<Value, Coordinator> {
        var difference: CoordinatorDifference?
    }
    
    let mapping: Mapping<[MapValue]>
    let differ: Differ<MapValue>
    let itemDiffer: Differ<Item>?
    
    var isSectioned = false
    var changes: Mapping<[DataSourceElement]> = ([], [])
    var uniqueChanges: Mapping<[DataSourceElement]> = ([], [])
    
    init(mapping: Mapping<[MapValue]>, differ: Differ<MapValue>, itemDiffer: Differ<Item>?) {
        self.mapping = mapping
        self.differ = differ
        self.itemDiffer = itemDiffer
        super.init()
    }
    
    override func prepareForGenerate() {
        (changes, uniqueChanges) = toChanges(mapping: mapping, differ: differ)
    }
    
    override func inferringMoves(context: Context) {
        
    }
}
