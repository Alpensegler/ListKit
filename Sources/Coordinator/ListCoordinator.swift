//
//  ListCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/11/25.
//

import ObjectiveC.runtime

public class ListCoordinator<SourceBase: DataSource>: ItemTypedCoorinator<SourceBase.Item> {
    typealias Item = SourceBase.Item
    
    var stagingContextSetups = [(ListContext<SourceBase>) -> Void]()
    var contexts = [ObjectIdentifier: ListContext<SourceBase>]()
    var source: SourceBase.Source { fatalError() }
    override var anySource: Any { source }
    
    override init() {
        super.init()
    }
    
    init(sourceBase: SourceBase) {
        super.init()
        
        selfType = ObjectIdentifier(SourceBase.self)
        itemType = ObjectIdentifier(SourceBase.Item.self)
    }
}

class SourceStoredListCoordinator<SourceBase: DataSource>: ListCoordinator<SourceBase> {
    var _source: SourceBase.Source
    override var source: SourceBase.Source { _source }
    
    func setup() { }
    
    override init(sourceBase: SourceBase) {
        _source = sourceBase.source
        
        super.init(sourceBase: sourceBase)
        setup()
    }
}

class WrapperCoordinator<SourceBase: DataSource>: ListCoordinator<SourceBase> {
    var wrappedCoodinator: BaseCoordinator { fatalError() }
    
    override var itemType: ObjectIdentifier {
        get { wrappedCoodinator.itemType }
        set { wrappedCoodinator.itemType = newValue }
    }
    
    override var sourceType: SourceType {
        get { wrappedCoodinator.sourceType }
        set { wrappedCoodinator.sourceType = newValue }
    }
    
    override var sourceIndices: [SourceIndices] {
        get { wrappedCoodinator.sourceIndices }
        set { wrappedCoodinator.sourceIndices = newValue }
    }
    
    override var rangeReplacable: Bool {
        get { wrappedCoodinator.rangeReplacable }
        set { wrappedCoodinator.rangeReplacable = newValue }
    }
    
    override func anyItem<Path: PathConvertible>(at path: Path) -> Any {
        wrappedCoodinator.anyItem(at: path)
    }
    
    override func anyItemSources<Source: DataSource>(source: Source) -> AnyItemSources {
        wrappedCoodinator.anyItemSources(source: source)
    }
    
    override func anyItemApplyMultiItem(changes: ValueChanges<Any, Int>) {
        wrappedCoodinator.anyItemApplyMultiItem(changes: changes)
    }
    
    override func anySectionSources<Source: DataSource>(source: Source) -> AnySectionSources {
        wrappedCoodinator.anySectionSources(source: source)
    }
    
    override func anySectionApplyMultiSection(changes: ValueChanges<[Any], Int>) {
        wrappedCoodinator.anySectionApplyMultiSection(changes: changes)
    }
    
    override func anySectionApplyItem(changes: [ValueChanges<Any, Int>]) {
        wrappedCoodinator.anySectionApplyItem(changes: changes)
    }
    
    override func anySourceUpdate(to sources: [AnyDiffableSourceValue]) {
        wrappedCoodinator.anySourceUpdate(to: sources)
    }
    
    override func applyBy(listView: ListView, sectionOffset: Int, itemOffset: Int) {
        super.applyBy(listView: listView, sectionOffset: sectionOffset, itemOffset: itemOffset)
        wrappedCoodinator.applyBy(listView: listView, sectionOffset: sectionOffset, itemOffset: itemOffset)
    }
}

class ItemTypedWrappedCoordinator<SourceBase: DataSource>: WrapperCoordinator<SourceBase> {
    var wrappedItemTypedCoodinator: ItemTypedCoorinator<SourceBase.Item> { fatalError() }
    
    override func item<Path: PathConvertible>(at path: Path) -> SourceBase.Item {
        wrappedItemTypedCoodinator.item(at: path)
    }
    
    override func itemSources<Source: DataSource>(source: Source) -> ItemSource
    where Source.SourceBase.Item == Item {
        wrappedItemTypedCoodinator.itemSources(source: source)
    }
    
    override func itemApplyMultiItem(changes: ValueChanges<Item, Int>) {
        wrappedItemTypedCoodinator.itemApplyMultiItem(changes: changes)
    }
    
    override func sectionSources<Source: DataSource>(source: Source) -> SectionSource
    where Source.SourceBase.Item == Item {
        wrappedItemTypedCoodinator.sectionSources(source: source)
    }
    
    override func sectionApplyMultiSection(changes: ValueChanges<[Item], Int>) {
        wrappedItemTypedCoodinator.sectionApplyMultiSection(changes: changes)
    }
    
    override func sectionApplyItem(changes: [ValueChanges<Item, Int>]) {
        wrappedItemTypedCoodinator.sectionApplyItem(changes: changes)
    }
    
    override func sourceUpdate(to sources: [DiffableSourceValue]) {
        wrappedItemTypedCoodinator.sourceUpdate(to: sources)
    }
}
