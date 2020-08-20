//
//  NSCoordinatorswift
//  ListKit
//
//  Created by Frain on 2020/6/10.
//

import Foundation

final class NSCoordinatorUpdate<SourceBase: NSDataSource>: ListCoordinatorUpdate<SourceBase>
where SourceBase.SourceBase == SourceBase {
    struct IndexPathSet {
        var sections = IndexSet()
        var items = [Int: IndexSet]()
        
        mutating func insert(_ indexPath: IndexPath) {
            sections.insert(indexPath.section)
            self[indexPath.section].insert(indexPath.item)
        }
        
        mutating func insert(_ indexPaths: [IndexPath]) {
            indexPaths.forEach { self.insert($0) }
        }
        
        mutating func remove(_ indexPath: IndexPath) {
            sections.remove(indexPath.section)
            self[indexPath.section].remove(indexPath.item)
        }
        
        subscript(key: Int) -> IndexSet {
            get { items[key] ?? .init() }
            set { items[key] = newValue }
        }
        
        func indexPaths(_ offset: IndexPath? = nil, _ ignoreSet: IndexSet? = nil) -> [IndexPath] {
            sections.flatMap { section -> [IndexPath] in
                guard ignoreSet?.contains(section) != true, let indexSet = items[section] else {
                    return []
                }
                return indexSet.map { IndexPath(offset, section: section, item: $0) }
            }
        }
    }
    
    weak var coordinator: NSCoordinator<SourceBase>?
    var indices: Mapping<Indices>
    var keepSectionIfEmpty = (source: false, target: false)
    
    var sectionChanges: Mapping<IndexSet> = (.init(), .init())
    var sectionAllChanges: Mapping<IndexSet> = (.init(), .init())
    var sectionReload = IndexSet()
    var sectionMove = IndexSet()
    
    var itemChanges: Mapping<IndexPathSet> = (.init(), .init())
    var itemAllChanges: Mapping<IndexPathSet> = (.init(), .init())
    var itemReload = IndexPathSet()
    var itemMove = IndexPathSet()
    
    var sectionDict = [Int: Int]()
    var itemDict = [IndexPath: IndexPath]()
    
    init(
        _ coordinator: NSCoordinator<SourceBase>,
        update: ListUpdate<SourceBase>,
        sources: Sources,
        indices: Mapping<Indices>,
        keepSectionIfEmpty: Mapping<Bool>,
        isSectioned: Bool
    ) {
        self.coordinator = coordinator
        self.indices = indices
        super.init(coordinator: coordinator, update: update, sources: sources)
        self.keepSectionIfEmpty = keepSectionIfEmpty
        self.isSectioned = isSectioned
    }
    
    func protectFromSectionItemBothChange() {
        itemMove.indexPaths().forEach {
            guard let indexPath = itemDict[$0] else { return }
            let sourceShouldIgnore = sectionAllChanges.source.contains(indexPath.section)
            let targetShouldIgnore = sectionAllChanges.target.contains($0.section)
            switch (sourceShouldIgnore, targetShouldIgnore) {
            case (false, false): return
            case (false, true): itemChanges.source.insert(indexPath)
            case (true, false): itemChanges.target.insert($0)
            case (true, true): break
            }
            itemDict[$0] = nil
        }
    }
    
    func itemSourceUpdates(_ offset: IndexPath?) -> BatchUpdates.ItemSource {
        return .init(
            all: itemAllChanges.source.indexPaths(offset, sectionAllChanges.source),
            deletes: itemChanges.source.indexPaths(offset, sectionAllChanges.source),
            reloads: itemReload.indexPaths(offset, sectionAllChanges.source),
            isEmpty: itemAllChanges.source.items.isEmpty
        )
    }
    
    func itemTargetUpdates(_ offset: Mapping<IndexPath>?) -> BatchUpdates.ItemTarget {
        var dict = [IndexPath: IndexPath]()
        dict.reserveCapacity(itemDict.count)
        let moves: [Mapping<IndexPath>] = itemMove.indexPaths().compactMap {
            guard let indexPath = itemDict[$0] else { return nil }
            let source = offset?.source.offseted(indexPath.section, indexPath.item) ?? indexPath
            let target = offset?.target.offseted($0.section, $0.item) ?? $0
            dict[target] = source
            return (source, target)
        }
        return .init(
            all: itemAllChanges.target.indexPaths(offset?.target, sectionAllChanges.target),
            inserts: itemChanges.target.indexPaths(offset?.target, sectionAllChanges.target),
            moves: moves,
            moveDict: dict,
            isEmpty: itemAllChanges.target.items.isEmpty
        )
    }
    
    override func configChangeType() -> ChangeType {
        if hasBatchUpdate { protectFromSectionItemBothChange() }
        return super.configChangeType()
    }
    
    override func getSourceCount() -> Int { indices.source.count }
    override func getTargetCount() -> Int { indices.target.count }
    
    override func updateData(_ isSource: Bool) {
        super.updateData(isSource)
        coordinator?.indices = indices.target
    }
    
    override func generateSourceUpdate(
        order: Order,
        context: UpdateContext<Int>? = nil
    ) -> UpdateSource<BatchUpdates.ListSource> {
        guard isSectioned else { return super.generateSourceUpdate(order: order, context: context) }
        switch order {
        case .first: return (sourceCount, nil)
        case .third: return (targetCount, nil)
        default: break
        }
        let section = BatchUpdates.SectionSource(
            all: sectionAllChanges.source.addingOffset(context?.offset),
            deletes: sectionChanges.source.addingOffset(context?.offset),
            reloads: sectionReload.addingOffset(context?.offset),
            isEmpty: sectionAllChanges.source.isEmpty
        )
        let item = itemSourceUpdates((context?.offset).map { .init(section: $0) })
        return (targetCount, .init(item: item, section: section))
    }
    
    override func generateTargetUpdate(
        order: Order,
        context: UpdateContext<Offset<Int>>? = nil
    ) -> UpdateTarget<BatchUpdates.ListTarget> {
        guard isSectioned else { return super.generateTargetUpdate(order: order, context: context) }
        switch order {
        case .first: return (toIndices(sourceCount, context), nil, nil)
        case .third: return (toIndices(targetCount, context), nil, nil)
        default: break
        }
        var dict = [Int: Int]()
        dict.reserveCapacity(sectionDict.count)
        let moves: [Mapping<Int>] = sectionMove.compactMap {
            guard let index = sectionDict[$0] else { return nil }
            let source = index + (context?.offset.offset.source ?? 0)
            let target = $0 + (context?.offset.offset.target ?? 0)
            dict[target] = source
            return (source, target)
        }
        let section = BatchUpdates.SectionTarget(
            all: sectionAllChanges.target.addingOffset(context?.offset.offset.target),
            inserts: sectionChanges.target.addingOffset(context?.offset.offset.target),
            moves: moves,
            moveDict: sectionDict,
            isEmpty: sectionAllChanges.target.isEmpty
        )
        let offset: Mapping<IndexPath>? = (context?.offset.offset).map {
            (IndexPath(section: $0.source), IndexPath(section: $0.target))
        }
        let item = itemTargetUpdates(offset)
        return (toIndices(targetCount, context), .init(item: item, section: section), finalChange)
    }
    
    override func generateSourceItemUpdate(
        order: Order,
        context: UpdateContext<IndexPath>? = nil
    ) -> UpdateSource<BatchUpdates.ItemSource> {
        if isMoreUpdate { return super.generateSourceItemUpdate(order: order, context: context) }
        switch order {
        case .first: return (sourceCount, nil)
        case .second: return (sourceCount, itemSourceUpdates(context?.offset))
        case .third: return (targetCount, nil)
        }
    }
    
    override func generateTargetItemUpdate(
        order: Order,
        context: UpdateContext<Offset<IndexPath>>? = nil
    ) -> UpdateTarget<BatchUpdates.ItemTarget> {
        if isMoreUpdate { return super.generateTargetItemUpdate(order: order, context: context) }
        switch order {
        case .first: return (toIndices(sourceCount, context), nil, nil)
        case .third: return (toIndices(targetCount, context), nil, nil)
        default: break
        }
        let update = itemTargetUpdates(context?.offset.offset)
        return (toIndices(targetCount, context), update, finalChange)
    }
}

extension NSCoordinatorUpdate {
    func insertSection(_ section: Int) {
        sectionChanges.target.insert(section)
        sectionAllChanges.target.insert(section)
    }
    
    func insertSections(_ sections: IndexSet) {
        sectionChanges.target.formUnion(sections)
        sectionAllChanges.target.formUnion(sections)
    }
    
    func deleteSection(_ section: Int) {
        sectionChanges.source.insert(section)
        sectionAllChanges.source.insert(section)
    }
    
    func deleteSections(_ sections: IndexSet) {
        sectionChanges.source.formUnion(sections)
        sectionAllChanges.source.formUnion(sections)
    }
    
    func reloadSection(_ section: Int, newSection: Int) {
        sectionReload.insert(section)
        sectionAllChanges.source.insert(section)
        sectionAllChanges.target.insert(newSection)
    }
    
    func reloadSections(_ sections: IndexSet, newSections: IndexSet) {
        sectionReload.formUnion(sections)
        sectionAllChanges.source.formUnion(sections)
        sectionAllChanges.target.formUnion(newSections)
    }
    
    func moveSection(_ section: Int, to newSection: Int) {
        sectionMove.insert(newSection)
        sectionDict[newSection] = section
        sectionAllChanges.source.insert(section)
        sectionAllChanges.target.insert(newSection)
    }
    
    func insertItem(at indexPath: IndexPath) {
        itemChanges.target.insert(indexPath)
        itemAllChanges.target.insert(indexPath)
    }
    
    func insertItems(at indexPaths: [IndexPath]) {
        itemChanges.target.insert(indexPaths)
        itemAllChanges.target.insert(indexPaths)
    }
    
    func deleteItem(at indexPath: IndexPath) {
        itemChanges.source.insert(indexPath)
        itemAllChanges.source.insert(indexPath)
    }
    
    func deleteItems(at indexPaths: [IndexPath]) {
        itemChanges.source.insert(indexPaths)
        itemAllChanges.source.insert(indexPaths)
    }
    
    func reloadItem(at indexPath: IndexPath, newIndexPath: IndexPath) {
        itemReload.insert(indexPath)
        itemAllChanges.source.insert(indexPath)
        itemAllChanges.target.insert(newIndexPath)
    }
    
    func reloadItems(at indexPaths: [IndexPath], newIndexPaths: [IndexPath]) {
        zip(indexPaths, newIndexPaths).forEach { reloadItem(at: $0.0, newIndexPath: $0.1) }
    }
    
    func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        itemMove.insert(newIndexPath)
        itemDict[newIndexPath] = indexPath
        itemAllChanges.source.insert(indexPath)
        itemAllChanges.target.insert(newIndexPath)
    }
}

extension IndexSet {
    func addingOffset(_ offset: Int?) -> IndexSet {
        guard let offset = offset else { return self }
        return .init(map { $0 + offset })
    }
}
