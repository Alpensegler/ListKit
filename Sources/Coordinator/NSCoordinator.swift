//
//  NSCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/3.
//

class NSCoordinator<Source: NSDataSource>: SourceListCoordinator<Source> {
    let itemClosure: (Path) -> Item
    let configSourceIndices: (NSCoordinator<Source>) -> Void
    
    override func item(at path: Path) -> Item { itemClosure(path) }
    
    override func anySectionSources<Source: DataSource>(source: Source) -> AnySectionSources {
        .other(Other(type: .noneDiffable, diffable: {
            .init(source: source, differ: source.updater.source, coordinator: self)
        }))
    }
    
    override func sectionSources<Source: DataSource>(source: Source) -> SectionSource {
        .other(Other(type: .noneDiffable, diffable: {
            .init(source: source, differ: source.updater.source, coordinator: self)
        }))
    }
    
    override init(value: Source) {
        itemClosure = { [unowned value] in value.item(at: $0.section, item: $0.item) }
        configSourceIndices = { [unowned value] in
            $0.sourceIndices = (0..<value.numbersOfSections()).map {
                .section(index: 0, count: value.numbersOfItem(in: $0))
            }
        }
        
        super.init(value: value)
        configSourceIndices(self)
        sourceType = .section
    }
}
