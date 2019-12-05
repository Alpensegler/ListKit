//
//  ItemTypedCoorinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/8.
//

public class ItemTypedCoorinator<Item>: BaseCoordinator {
    typealias ItemSource = SourceValue<Never, ItemTypedCoorinator<Item>, Item, Item>
    typealias SectionSource = SectionSourceValue<ItemTypedCoorinator<Item>, [Item], Item>
    typealias DiffableSourceValue = DiffableValue<ItemTypedCoorinator<Item>>
    
    func item<Path: PathConvertible>(at path: Path) -> Item { fatalError() }
    
    func itemSources<Source: DataSource>(source: Source) -> ItemSource
    where Source.SourceBase.Item == Item { fatalError() }
    
    func itemApplyMultiItem(changes: ValueChanges<Item, Int>) { fatalError() }
    
    func sectionSources<Source: DataSource>(source: Source) -> SectionSource
    where Source.SourceBase.Item == Item { fatalError() }
    
    func sectionApplyMultiSection(changes: ValueChanges<[Item], Int>) { fatalError() }
    func sectionApplyItem(changes: [ValueChanges<Item, Int>]) { fatalError() }
    
    func sourceUpdate(to sources: [DiffableSourceValue]) { fatalError() }
    
    override func anyItem<Path: PathConvertible>(at path: Path) -> Any { item(at: path) }
}
