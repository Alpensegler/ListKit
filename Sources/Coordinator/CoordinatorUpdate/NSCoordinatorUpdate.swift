//
//  NSCoordinatorswift
//  ListKit
//
//  Created by Frain on 2020/6/10.
//

import Foundation

final class NSCoordinatorUpdate<SourceBase: NSDataSource>: ListCoordinatorUpdate<SourceBase>
where SourceBase.SourceBase == SourceBase {
    
    weak var coordinator: NSCoordinator<SourceBase>?
    var indices: Mapping<Indices>
    
    var _section: ChangeSets<IndexSet>?
    var _item: ChangeSets<IndexPathSet>?
    
    var section: ChangeSets<IndexSet> {
        get { _section.or(.init()) }
        set { _section = newValue }
    }
    
    var item: ChangeSets<IndexPathSet> {
        get { _item.or(.init()) }
        set { _item = newValue }
    }
    
    override var sourceCount: Int { indices.source.count }
    override var targetCount: Int { indices.target.count }
    
    init(
        _ coordinator: NSCoordinator<SourceBase>,
        update: ListUpdate<SourceBase>,
        sources: Sources,
        indices: Mapping<Indices>,
        options: Options
    ) {
        self.coordinator = coordinator
        self.indices = indices
        super.init(coordinator, update: update, sources: sources, options: options)
        isItems = !coordinator.sectioned
    }
    
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
        let section = _section?.toSource(offset: context?.offset)
        let item = _item?.toSource(offset: (context?.offset).map { .init(section: $0) })
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
        let offset: Mapping<IndexPath>? = (context?.offset.offset).map {
            (IndexPath(section: $0.source), IndexPath(section: $0.target))
        }
        let section = _section?.toTarget(offset: context?.offset.offset)
        let item = _item?.toTarget(offset: offset)
        return (toIndices(targetCount, context), .init(item: item, section: section), finalChange)
    }
    
    override func generateSourceItemUpdate(
        order: Order,
        context: UpdateContext<IndexPath>? = nil
    ) -> UpdateSource<BatchUpdates.ItemSource> {
        if isMoreUpdate { return super.generateSourceItemUpdate(order: order, context: context) }
        switch order {
        case .first: return (sourceCount, nil)
        case .second: return (sourceCount, _item?.toSource(offset: context?.offset))
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
        let update = _item?.toTarget(offset: context?.offset.offset)
        return (toIndices(targetCount, context), update, finalChange)
    }
}
