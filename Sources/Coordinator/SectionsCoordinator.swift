//
//  SectionsCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/3.
//

import Foundation

class SectionsCoordinator<SourceBase: DataSource>: ListCoordinator<SourceBase>
where
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: Collection,
    SourceBase.Source.Element: Collection,
    SourceBase.Source.Element.Element == SourceBase.Item
{
    lazy var sections = toSections(source)
    lazy var indices = toIndices(sections)
    
    var updateType: SectionsCoordinatorUpdate<SourceBase>.Type {
        SectionsCoordinatorUpdate<SourceBase>.self
    }
    
    func toSections(_ source: SourceBase.Source) -> ContiguousArray<ContiguousArray<Item>> {
        source.mapContiguous { $0.mapContiguous { $0 } }
    }
    
    func toIndices(_ sections: ContiguousArray<ContiguousArray<Item>>) -> Indices {
        if options.keepEmptySection { return sections.indices.mapContiguous { ($0, false) } }
        var indices = Indices(capacity: sections.count)
        for (i, section) in sections.enumerated() where !section.isEmpty {
            indices.append((i, false))
        }
        return indices
    }
    
    override func item(at indexPath: IndexPath) -> Item {
        sections[indices[indexPath.section].index][indexPath.item]
    }
    
    override func numbersOfSections() -> Int { indices.count }
    override func numbersOfItems(in section: Int) -> Int {
        let index = indices[section]
        if index.isFake { return 0 }
        return sections[index.index].count
    }
    
    override func isSectioned() -> Bool { true }
    
    override func update(
        from coordinator: ListCoordinator<SourceBase>,
        updateWay: ListUpdateWay<Item>?
    ) -> CoordinatorUpdate {
        let coordinator = coordinator as! SectionsCoordinator<SourceBase>
        return updateType.init(
            coordinator: self,
            update: ListUpdate(updateWay, or: update),
            values: (coordinator.sections, sections),
            sources: (coordinator.source, source),
            indices: (coordinator.indices, indices),
            keepSectionIfEmpty: (coordinator.options.keepEmptySection, options.keepEmptySection)
        )
    }
    
    override func update(_ update: ListUpdate<SourceBase>) -> CoordinatorUpdate {
        let sourcesAfterUpdate = update.source
        let sectionsAfterUpdate = sourcesAfterUpdate.map(toSections)
        let indicesAfterUpdate =  sectionsAfterUpdate.map(toIndices)
        return updateType.init(
            coordinator: self,
            update: update,
            values: (sections, sectionsAfterUpdate ?? sections),
            sources: (source, sourcesAfterUpdate ?? source),
            indices: (indices, indicesAfterUpdate ?? indices),
            keepSectionIfEmpty: (options.keepEmptySection, options.keepEmptySection)
        )
    }
}


final class RangeReplacableSectionsCoordinator<SourceBase: DataSource>:
    SectionsCoordinator<SourceBase>
where
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: RangeReplaceableCollection,
    SourceBase.Source.Element.Element == SourceBase.Item
{
    override var updateType: SectionsCoordinatorUpdate<SourceBase>.Type {
        RangeReplacableSectionsCoordinatorUpdate<SourceBase>.self
    }
}
