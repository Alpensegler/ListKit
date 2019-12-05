//
//  WrapperCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/10.
//

import ObjectiveC.runtime

class WrapperCoordinator<Source: DataSource>: ListCoordinator<Source> {
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
    
    override func responds(to aSelector: Selector!) -> Bool {
        wrappedCoodinator.responds(to: aSelector) || super.responds(to: aSelector)
    }
    
    override func apply<Object: AnyObject, Input, Output>(
        _ keyPath: KeyPath<BaseCoordinator, ClosureDelegate<Object, Input, Output>>,
        object: Object,
        with input: Input
    ) -> Output {
        wrappedCoodinator.responds(to: self[keyPath: keyPath].selector)
            ? wrappedCoodinator.apply(keyPath, object: object, with: input)
            : super.apply(keyPath, object: object, with: input)
    }
    
    override func apply<Object: AnyObject, Input>(
        _ keyPath: KeyPath<BaseCoordinator, ClosureDelegate<Object, Input, Void>>,
        object: Object,
        with input: Input
    ) {
        if wrappedCoodinator.responds(to: self[keyPath: keyPath].selector) {
            wrappedCoodinator.apply(keyPath, object: object, with: input)
        }
        super.apply(keyPath, object: object, with: input)
    }
}

class ItemTypedWrappedCoordinator<Source: DataSource>: WrapperCoordinator<Source> {
    var wrappedItemTypedCoodinator: ItemTypedCoorinator<Source.Item> { fatalError() }
    
    override func item<Path: PathConvertible>(at path: Path) -> Source.Item {
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
