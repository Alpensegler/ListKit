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
    
    override var section: ChangeSets<IndexSet> {
        get { _section.or(.init()) }
        set { _section = newValue }
    }
    
    override var item: ChangeSets<IndexPathSet> {
        get { _item.or(.init()) }
        set { _item = newValue }
    }
    
    init(
        coordinator: NSCoordinator<SourceBase>,
        update: ListUpdate<SourceBase>?,
        sources: Sources,
        indices: Mapping<Indices>,
        options: Options
    ) {
        self.coordinator = coordinator
        self.indices = indices
        super.init(coordinator, update: update, sources: sources, options: options)
        if isBatchUpdate { target = sources.target }
    }
    
    override func configSourceCount() -> Int { indices.source.count }
    override func configTargetCount() -> Int { indices.target.count }
    
    override func configUpdateWay() -> UpdateWay? {
        _item != nil || _section != nil ? .batch : super.configUpdateWay()
    }
    
    override func configMaxOrderForContext(_ ids: [AnyHashable]) -> Order? {
        if _item != nil && sourceType.isItems { return .second }
        if _section != nil { return .first }
        return super.configMaxOrderForContext(ids)
    }
    
    override func updateData(_ isSource: Bool, containsSubupdate: Bool) {
        super.updateData(isSource, containsSubupdate: containsSubupdate)
        coordinator?.indices = indices.target
    }
    
    override func customUpdateWay() -> UpdateWay? {
        if isBatchUpdate { return .batch }
        return .other(.reload)
    }
    
    override func generateSourceUpdate(
        order: Order,
        context: UpdateContext<Int> = (nil, false, [])
    ) -> UpdateSource<BatchUpdates.ListSource> {
        switch order {
        case .second: return (targetCount, nil)
        case .third: return (targetCount, nil)
        default: break
        }
        let section = _section?.source.offseted(by: context.offset)
        let item = _item?.source.offseted(by: (context.offset).map { IndexPath(section: $0) })
        return (sourceCount, .init(item: item, section: section))
    }
    
    override func generateTargetUpdate(
        order: Order,
        context: UpdateContext<Offset<Int>> = (nil, false, [])
    ) -> UpdateTarget<BatchUpdates.ListTarget> {
        switch order {
        case .second: return (toIndices(targetCount, context), nil, nil)
        case .third: return (toIndices(targetCount, context), nil, nil)
        default: break
        }
        let offset: Mapping<IndexPath>? = (context.offset?.offset).map {
            (IndexPath(section: $0.source), IndexPath(section: $0.target))
        }
        let section = _section?.target.offseted(by: context.offset?.offset)
        let item = _item?.target.offseted(by: offset)
        return (toIndices(targetCount, context), .init(item: item, section: section), finalChange())
    }
    
    override func generateSourceItemUpdate(
        order: Order,
        context: UpdateContext<IndexPath> = (nil, false, [])
    ) -> UpdateSource<BatchUpdates.ItemSource> {
        switch order {
        case .first: return (sourceCount, nil)
        case .second: return (sourceCount, _item?.source.offseted(by: context.offset))
        case .third: return (targetCount, nil)
        }
    }
    
    override func generateTargetItemUpdate(
        order: Order,
        context: UpdateContext<Offset<IndexPath>> = (nil, false, [])
    ) -> UpdateTarget<BatchUpdates.ItemTarget> {
        switch order {
        case .first: return (toIndices(sourceCount, context), nil, nil)
        case .third: return (toIndices(targetCount, context), nil, nil)
        default: break
        }
        let update = _item?.target.offseted(by: context.offset?.offset)
        return (toIndices(targetCount, context), update, finalChange())
    }
}
