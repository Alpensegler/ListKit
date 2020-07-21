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
    
    override var multiType: SourceMultipleType { .multiple }
    override var isEmpty: Bool { indices.isEmpty }
    
    func toSections(_ source: SourceBase.Source) -> ContiguousArray<ContiguousArray<Item>> {
        source.mapContiguous { $0.mapContiguous { $0 } }
    }
    
    func toIndices(_ sections: ContiguousArray<ContiguousArray<Item>>) -> ContiguousArray<Int> {
        if options.keepEmptySection { return sections.indices.mapContiguous { $0 } }
        var offsets = ContiguousArray<Int>(capacity: sections.count)
        for (i, section) in sections.enumerated() where !section.isEmpty {
            offsets.append(i)
        }
        return offsets
    }
    
    override func item(at section: Int, _ item: Int) -> Item { sections[indices[section]][item] }
    
    override func numbersOfSections() -> Int { indices.count }
    override func numbersOfItems(in section: Int) -> Int {
        sections[safe: indices[section]]?.count ?? 0
    }
    
    override func isSectioned() -> Bool { true }
    
    override func update(
        from coordinator: ListCoordinator<SourceBase>,
        differ: Differ<Item>?
    ) -> CoordinatorUpdate<SourceBase> {
        let coordinator = coordinator as! SectionsCoordinator<SourceBase>
        return updateType.init(
            coordinator: self,
            update: Update(differ, or: update),
            values: (coordinator.sections, sections),
            sources: (coordinator.source, source),
            indices: (coordinator.indices, indices),
            keepSectionIfEmpty: (coordinator.options.keepEmptySection, options.keepEmptySection)
        )
    }
    
    override func update(_ update: Update<SourceBase>) -> CoordinatorUpdate<SourceBase> {
        let sourcesAfterUpdate = update.source
        let sectionsAfterUpdate = sourcesAfterUpdate.map(toSections)
        let indicesAfterUpdate =  sectionsAfterUpdate.map(toIndices)
        defer {
            sections = sectionsAfterUpdate ?? sections
            source = sourcesAfterUpdate ?? source
            indices = indicesAfterUpdate ?? indices
        }
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


final class RangeReplacableSectionsCoordinator<SourceBase: DataSource>: SectionsCoordinator<SourceBase>
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
