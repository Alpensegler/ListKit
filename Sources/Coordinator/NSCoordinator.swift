//
//  NSCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/3.
//

final class NSCoordinator<SourceBase: NSDataSource>: ListCoordinator<SourceBase>
where SourceBase.SourceBase == SourceBase {
    let itemClosure: (Int, Int) -> Item
    let configSourceIndices: (NSCoordinator<SourceBase>) -> Void
    
    override var multiType: SourceMultipleType { .noneDiffable }
    
    override func item(at path: PathConvertible) -> Item {
        itemClosure(path.section, path.item)
    }
    
//    override func anySectionSources<Source: DataSource>(source: Source) -> AnySectionSources {
//        .other(Other(type: .noneDiffable, diffable: {
//            .init(source: source, differ: source.updater.source, coordinator: self)
//        }))
//    }
//
//    override func sectionSources<Source: DataSource>(source: Source) -> SectionSource {
//        .other(Other(type: .noneDiffable, diffable: {
//            .init(source: source, differ: source.updater.source, coordinator: self)
//        }))
//    }
    
    init(_ sourceBase: SourceBase) {
        itemClosure = { [unowned sourceBase] in sourceBase.item(at: $0, item: $1) }
        configSourceIndices = { [unowned sourceBase] in
            $0.sourceIndices = (0..<sourceBase.numbersOfSections()).map {
                .section(index: 0, count: sourceBase.numbersOfItem(in: $0))
            }
        }
        
        super.init(sourceBase, storage: sourceBase.coordinatorStorage)
        configSourceIndices(self)
        sourceType = .section
    }
}
