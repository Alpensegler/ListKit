//
//  ItemCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/10/10.
//

class ItemCoordinator<Source: DataSource>: SourceListCoordinator<Source>
where Source.Item == Source.Source {
    override func item(at path: Path) -> Item { source }
    
    override func setup() {
        sourceIndices = [.cell(indices: [0])]
    }
    
    override func anyItemSources<Source: DataSource>(source: Source) -> AnyItemSources {
        .single(.init(item: source, coordinator: self) { self.source })
    }
    
    override func itemSources<Source: DataSource>(source: Source) -> ItemSource {
        .single(.init(item: source, coordinator: self) { self.source })
    }
}
