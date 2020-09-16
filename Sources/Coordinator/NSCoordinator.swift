//
//  NSCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/3.
//

import Foundation

final class NSCoordinator<SourceBase: NSDataSource>: ListCoordinator<SourceBase>
where SourceBase.SourceBase == SourceBase {
    unowned let sourceBase: SourceBase
    lazy var indices = toIndices(source)
    
    func toIndices(_ source: [Int]) -> Indices {
        if sourceType == .items {
            guard let index = source[safe: 0], index != 0 else { return [] }
            return (0..<index).mapContiguous { ($0, false) }
        }
        if !options.removeEmptySection { return source.indices.mapContiguous { ($0, false) } }
        var indices = Indices(capacity: source.count)
        for (i, section) in source.enumerated() where section != 0 { indices.append((i, false)) }
        return indices
    }
    
    override func numbersOfSections() -> Int { sourceType.isSection ? indices.count : 1 }
    override func numbersOfItems(in section: Int) -> Int {
        if sourceType == .items { return indices.count }
        guard let index = indices[safe: section], !index.isFake else { return 0 }
        return source[index.index]
    }
    
    override func item(at indexPath: IndexPath) -> Item { sourceBase.item(at: indexPath) }
    override func configSourceType() -> SourceType {
        isSectioned || source.count > 1 ? .section : .items
    }
    
    override init(_ sourceBase: SourceBase) {
        self.sourceBase = sourceBase
        super.init(sourceBase)
    }
    
    override func update(
        from coordinator: ListCoordinator<SourceBase>,
        updateWay: ListUpdateWay<Item>?
    ) -> ListCoordinatorUpdate<SourceBase> {
        let coordinator = coordinator as! NSCoordinator<SourceBase>
        return NSCoordinatorUpdate(
            self,
            update: .init(updateWay, or: update),
            sources: (coordinator.source, source),
            indices: (coordinator.indices, indices),
            options: (coordinator.options, options)
        )
    }

    override func update(
        update: ListUpdate<SourceBase>,
        options: ListOptions? = nil
    ) -> ListCoordinatorUpdate<SourceBase> {
        let sourcesAfterUpdate = update.source
        let indicesAfterUpdate = update.source.map(toIndices)
        return NSCoordinatorUpdate(
            self,
            update: update,
            sources: (source, sourcesAfterUpdate ?? source),
            indices: (indices, indicesAfterUpdate ?? indices),
            options: (self.options, options ?? self.options)
        )
    }
}
