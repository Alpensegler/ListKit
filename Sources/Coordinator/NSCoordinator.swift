//
//  NSCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/3.
//

class NSCoordinator<SourceBase: NSDataSource>: ListCoordinator<SourceBase> {
    let itemClosure: (Int, Int) -> Item
    let configSourceIndices: (NSCoordinator<SourceBase>) -> Void
    
    override func item<Path: PathConvertible>(at path: Path) -> Item {
        itemClosure(path.section, path.item)
    }
    
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
    
    override init(sourceBase: SourceBase) {
        itemClosure = { [unowned sourceBase] in sourceBase.item(at: $0, item: $1) }
        configSourceIndices = { [unowned sourceBase] in
            $0.sourceIndices = (0..<sourceBase.numbersOfSections()).map {
                .section(index: 0, count: sourceBase.numbersOfItem(in: $0))
            }
        }
        
        super.init(sourceBase: sourceBase)
        configSourceIndices(self)
        sourceType = .section
    }
}
