//
//  ItemSourcesCoordinator.swift
//  ListKit
//
//  Created by Frain on 2020/1/13.
//

class SourcesCoordinatorBase<SourceBase: DataSource>: ListCoordinator<SourceBase>
where
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: DataSource,
    SourceBase.Source.Element.SourceBase.Item == SourceBase.Item
{
    enum Source: DiffEquatable {
        case other
        case value(Diffable<Element>)
        
        func diffEqual(to other: Self, default value: Bool) -> Bool {
            switch (self, other) {
            case (.other, .other): return true
            case let (.value(lhs), .value(rhs)): return lhs.diffEqual(to: rhs)
            default: return false
            }
        }
    }
    
    typealias Element = SourceBase.Source.Element
    typealias Subcoordinator = ListCoordinator<Element.SourceBase>
    
    override var multiType: SourceMultipleType { .sources }
    
    var subsources = [Element]()
    var subcoordinators = [Subcoordinator]()
    var sourceIndices = [SourceIndices]()
    
    //Diff
    override func sourcesDifference(
        from coordinator: BaseCoordinator,
        differ: Differ<Item>
    ) -> Difference<BaseCoordinator> {
//        let coordinator = coordinator as! SourcesCoordinatorBase<SourceBase>
//        let (selfItems, selfCoordinators) = itemSourcesAndCoordinators()
//        let (fromItems, fromCoordinators) = coordinator.itemSourcesAndCoordinators()
//        let diff = selfItems.diff(
//            from: fromItems,
//            sourceCaches: selfCoordinators as [BaseCoordinator],
//            targetCaches: fromCoordinators as [BaseCoordinator],
//            differ: { .init($0.differ) { $0.value } },
//            areEquivalent: { $0.diffEqual(to: $1) }
//        )
//        return diff
        fatalError()
    }
    
    func sectionSourcesAndCoordinators() -> (values: [Source], coordinators: [BaseCoordinator]) {
        var cellSources = [(Element, Subcoordinator)]()
        var sources = [Source]()
        var coordinators = [BaseCoordinator]()
        for (element, coordinator) in zip(subsources, subcoordinators) {
            switch (cellSources.isEmpty, coordinator.sourceType) {
            case (_, .cell):
                cellSources.append((element, coordinator))
            case (false, .section):
                sources.append(.other)
                cellSources.removeAll()
                fallthrough
            case (true, .section):
                let diffable = Diffable(
                    id: coordinator.id,
                    differ: .init(coordinator.differ) { $0.sourceBase },
                    value: element
                )
                sources.append(.value(diffable))
                coordinators.append(coordinator)
            }
        }
        return (sources, coordinators)
    }
    
    func itemSourcesAndCoordinators() -> (values: [Diffable<Element>], coordinators: [BaseCoordinator]) {
        (zip(subsources, subcoordinators).map {
            Diffable(id: $0.1.id, differ: .init($0.1.differ) { $0.sourceBase }, value: $0.0)
        }, subcoordinators)
    }
}

class ItemSourcesCoordinator<Element>: BaseCoordinator where Element: DataSource {
    var elements: [Element]
    var coordinators: [ListCoordinator<Element.SourceBase>]
    
    init(elements: [Element], coordinators: [ListCoordinator<Element.SourceBase>]) {
        self.elements = elements
        self.coordinators = coordinators
        super.init()
    }
}
