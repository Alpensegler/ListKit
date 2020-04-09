//
//  ItemCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/10/10.
//

final class ItemCoordinator<SourceBase: DataSource>: SourceStoredListCoordinator<SourceBase>
where SourceBase.Item == SourceBase.Source, SourceBase.SourceBase == SourceBase  {
    override func item(at path: PathConvertible) -> Item { source }
    
    override var multiType: SourceMultipleType { .single }
    
    override func setup() {
        super.setup()
        sourceType = selectorSets.hasIndex ? .section : .cell
    }
    
//    override func anyItemSources<Source: DataSource>(source: Source) -> AnyItemSources {
//        .single(.init(item: source, coordinator: self) { self.source })
//    }
//
//    override func anySectionSources<Source: DataSource>(source: Source) -> AnySectionSources {
//        .single(.init(source: source, coordinator: self) { [self.source] })
//    }
//
//    override func itemSources<Source: DataSource>(source: Source) -> ItemSource {
//        .single(.init(item: source, coordinator: self) { self.source })
//    }
//
//    override func sectionSources<Source: DataSource>(source: Source) -> SectionSource {
//        .single(.init(source: source, coordinator: self) { [self.source] })
//    }
}
