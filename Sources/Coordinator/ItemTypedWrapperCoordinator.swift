//
//  ItemTypedWrapperCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//


class ItemTypedWrapperCoordinator<SourceBase: DataSource>: WrapperCoordinator<SourceBase> {
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
