//
//  ItemCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/10/10.
//

class ItemCoordinator<SourceBase: DataSource>: SourceStoredListCoordinator<SourceBase>
where SourceBase.Item == SourceBase.Source {
    override func item<Path: PathConvertible>(at path: Path) -> Item { source }
    
    override func setup(with delegates: Delegates) {
        sourceType = delegates.selectorSets.hasIndex ? .section : .cell
        sourceIndices = [.cell(indices: [0])]
    }
    
    override func anyItemSources<Source: DataSource>(source: Source) -> AnyItemSources {
        .single(.init(item: source, coordinator: self) { self.source })
    }
    
    override func itemSources<Source: DataSource>(source: Source) -> ItemSource {
        .single(.init(item: source, coordinator: self) { self.source })
    }
}
