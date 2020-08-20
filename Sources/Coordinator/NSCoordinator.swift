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
    
    override var isEmpty: Bool { numbersOfSections() == 0 }
    
    func toIndices(_ source: [Int]) -> Indices {
        guard sectioned else {
            guard let index = source[safe: 0], index != 0 else { return [] }
            return (0..<index).mapContiguous { ($0, false) }
        }
        if options.keepEmptySection { return source.indices.mapContiguous { ($0, false) } }
        var indices = Indices(capacity: source.count)
        for (i, section) in source.enumerated() where section != 0 { indices.append((i, false)) }
        return indices
    }
    
    override func numbersOfSections() -> Int { indices.count }
    override func numbersOfItems(in section: Int) -> Int {
        guard let index = indices[safe: section], !index.isFake else { return 0 }
        return source[index.index]
    }
    
    override func item(at section: Int, _ item: Int) -> Item {
        sourceBase.item(at: indices[section].index, item)
    }
    
    override func isSectioned() -> Bool {
        options.preferSection || super.isSectioned() || source.count > 1
    }
    
    override init(_ sourceBase: SourceBase) {
        self.sourceBase = sourceBase
        super.init(sourceBase)
    }
    
    override func update(
        from coordinator: ListCoordinator<SourceBase>,
        updateWay: ListUpdateWay<Item>?
    ) -> CoordinatorUpdate {
        let coordinator = coordinator as! NSCoordinator<SourceBase>
        return NSCoordinatorUpdate(
            self,
            update: .init(updateWay, or: update),
            sources: (coordinator.source, source),
            indices: (coordinator.indices, indices),
            keepSectionIfEmpty: (coordinator.options.keepEmptySection, options.keepEmptySection),
            isSectioned: sectioned
        )
    }

    override func update(_ update: ListUpdate<SourceBase>) -> CoordinatorUpdate {
        let sourcesAfterUpdate = sourceBase.source
        let indicesAfterUpdate = toIndices(sourcesAfterUpdate)
        defer {
            source = sourcesAfterUpdate
            indices = indicesAfterUpdate
        }
        return NSCoordinatorUpdate(
            self,
            update: update,
            sources: (source, sourcesAfterUpdate),
            indices: (indices, indicesAfterUpdate),
            keepSectionIfEmpty: (options.keepEmptySection, options.keepEmptySection),
            isSectioned: sectioned
        )
    }
}
