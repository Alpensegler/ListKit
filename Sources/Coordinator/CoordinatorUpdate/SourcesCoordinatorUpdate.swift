//
//  SourcesCoordinatorUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/7/12.
//

import Foundation

class SourcesCoordinatorUpdate<SourceBase: DataSource, Source: RangeReplaceableCollection>:
    ContainerCoordinatorUpdate<SourceBase, Source, SourceElement<Source.Element>>
where
    SourceBase.SourceBase == SourceBase,
    Source.Element: DataSource,
    Source.Element.SourceBase.Item == SourceBase.Item
{
    typealias Value = SourceElement<Source.Element>
    typealias Subcoordinator = ListCoordinator<Element.SourceBase>
    
    weak var coordinator: SourcesCoordinator<SourceBase, Source>?
    
    let subsourceType: SourcesCoordinator<SourceBase, Source>.SubsourceType
    
    override var diffable: Bool { true }
    override var equatable: Bool { true }
    override var identifiable: Bool { true }
    override var moveAndReloadable: Bool { !noneDiffUpdate }
    
    required init(
        coordinator: SourcesCoordinator<SourceBase, Source>,
        update: ListUpdate<SourceBase>?,
        values: Mapping<Values>,
        sources: Sources,
        indices: Mapping<Indices>,
        options: Options
    ) {
        self.subsourceType = coordinator.subsourceType
        self.coordinator = coordinator
        super.init(coordinator, update, values, sources, indices, options)
    }
    
    override func withOffset(_ value: Value, offset: Int, count: Int? = nil) -> Value {
        value.setting(offset: offset, count: count)
    }
    
    override func toIdentifier(_ value: Value) -> ObjectIdentifier {
        ObjectIdentifier(value.context)
    }
    
    override func toIndices(_ values: Values) -> Indices {
        SourcesCoordinator<SourceBase, Source>.toIndices(values)
    }
    
    override func subupdate(from value: Mapping<Value>) -> Subupdate {
        let way = differ.map { ListUpdateWay.diff($0) }
        return value.target.coordinator.update(from: value.source.coordinator, updateWay: way)
    }
    
    override func changeWhenHasNext(values: Values, source: SourceBase.Source?, indices: Indices) {
        guard let coordinator = self.coordinator else { return }
        Log.log("\(self) set indices: \(indices.map { $0 })")
        Log.log("\(self) set subsources: \(values.map { $0 })")
        coordinator.subsources = coordinator.settingIndex(values)
        coordinator.indices = indices
        coordinator.resetDelegates()
        coordinator.source = source
    }
    
    override func isEqual(lhs: Value, rhs: Value) -> Bool {
        let related = lhs.context
        switch (lhs.element, rhs.element) {
        case let (.element(lhs), .element(rhs)):
            return related.listCoordinator.equal(lhs: lhs.sourceBase, rhs: rhs.sourceBase)
        case let (.items(lhs, _), .items(rhs, _)):
            return lhs == rhs
        default:
            return false
        }
    }
    
    override func identifier(for value: Value) -> AnyHashable {
        switch value.element {
        case .element(let element):
            return [0, value.coordinator.identifier(for: element.sourceBase)] as [AnyHashable]
        case .items(let id, _):
            return [1, id] as [AnyHashable]
        }
    }
    
    override func isDiffEqual(lhs: Value, rhs: Value) -> Bool {
        guard identifier(for: lhs) == identifier(for: rhs) else { return false }
        return isEqual(lhs: lhs, rhs: rhs)
    }
    
    override func associateChange(_ mapping: Mapping<Change>, ids: Mapping<[AnyHashable]>) {
        let source = mapping.source.value.coordinator
        let target = mapping.target.value.coordinator
        let update = target.update(from: source, updateWay: updateWay)
        mapping.source.update[ids.source] = update
        mapping.target.update[ids.target] = update
    }

    override func toValue(_ element: Element) -> Value {
        let context = element.listCoordinatorContext, coordinator = element.listCoordinator
        if coordinator.sourceType == .items, sourceType == .section {
            let c = context.numbersOfItems(in: 0)
            let source = Value(element: .element(element), context: context, offset: 0, count: c)
            let coordinator = SourcesCoordinator<Source.Element.SourceBase, [Source.Element]>(
                elements: [source],
                update: .init(way: updateWay)
            )
            let context = coordinator.context(with: .init())
            source.context.isSectioned = false
            coordinator.addContext(to: source.context)
            self.coordinator.map { $0.addContext(to: context) }
            let item = Value.Subelement.items(id: coordinator.id) { coordinator.subsourcesArray }
            let count = context.numbersOfSections()
            coordinator.id += 1
            return .init(element: item, context: context, offset: 0, count: count)
        } else {
            let count = sourceType.isSection ? context.numbersOfSections() : context.numbersOfItems(in: 0)
            self.coordinator.map { $0.addContext(to: context) }
            return .init(element: .element(element), context: context, offset: 0, count: count)
        }
    }
    
    override func toCount(_ value: Value) -> Int { value.count }
    
    override func toChange(_ value: Value, _ index: Int) -> Change {
        let change = Change(value: value, index: index, value.coordinator, moveAndReloadable)
        change.coordinatorUpdate = self
        return change
    }
    
    override func toSource(_ values: ContiguousArray<Value>) -> SourceBase.Source? {
        guard case let .fromSourceBase(_, map) = subsourceType else { return nil }
        return map(.init(values.flatMap { subsource -> ContiguousArray<Element> in
            switch subsource.element {
            case let .items(_, items): return items()
            case let .element(element): return [element]
            }
        }))
    }
    
    override func configTargetValues() -> Values {
        var offset = 0, index = 0
        func append(value: Value, count: Int? = nil, to target: inout Values) {
            let value = value.setting(offset: offset, count: count)
            value.context.index = index
            target.append(value)
            (offset, index) = (offset + value.count, index + 1)
        }
        
        return enumerateChangesForTarget(offset: { (from, to, source, target) in
            for index in from..<to {
                let value = source[index]
                if let subupdate = subupdates[index] {
                    append(value: value, count: subupdate.targetCountForContainer, to: &target)
                } else {
                    append(value: value, to: &target)
                }
            }
        }, append: { (value, target) in
            append(value: value, to: &target)
        })
    }
    
    // override from CoordinatorUpdate
    
    override func inferringMoves(context: Context? = nil, ids: [AnyHashable] = []) {
        if !isBatchUpdate { _ = uniqueDict }
        super.inferringMoves(context: context)
    }
    
    override func updateData(_ isSource: Bool, containsSubupdate: Bool) {
        if containsSubupdate {
            subupdates.values.forEach { $0.updateData(isSource, containsSubupdate: true) }
        }
        super.updateData(isSource, containsSubupdate: containsSubupdate)
        guard let coordinator = coordinator else { return }
        coordinator.subsources = isSource ? sourceValues : targetValues
        coordinator.indices = isSource ? sourceIndices : targetIndices
        if !isSource { coordinator.resetDelegates() }
    }
}

final class DataSourcesCoordinatorUpdate<SourceBase: DataSource>:
    SourcesCoordinatorUpdate<SourceBase, SourceBase.Source>
where
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: DataSource,
    SourceBase.Source.Element.Item == SourceBase.Item
{
    
    override func insert(_ element: SourceBase.Source.Element, at index: Int)
    where SourceBase.Source: RangeReplaceableCollection {
        insertElement(element, at: index)
    }
        
    override func insert<C: Collection>(contentsOf elements: C, at index: Int)
    where SourceBase.Source: RangeReplaceableCollection, C.Element == SourceBase.Source.Element {
        insertElements(contentsOf: elements, at: index)
    }
        
    override func append(_ element: SourceBase.Source.Element)
    where SourceBase.Source: RangeReplaceableCollection {
        appendElement(element)
    }
        
    override func append<S: Sequence>(contentsOf elements: S)
    where SourceBase.Source: RangeReplaceableCollection, S.Element == SourceBase.Source.Element {
        appendElements(contentsOf: elements)
    }
        
    override func remove(at index: Int)
    where SourceBase.Source: RangeReplaceableCollection {
        removeElement(at: index)
    }
    
    override func remove(at indexSet: IndexSet)
    where SourceBase.Source: RangeReplaceableCollection {
        removeElements(at: indexSet)
    }
        
    override func update(_ element: SourceBase.Source.Element, at index: Int)
    where SourceBase.Source: RangeReplaceableCollection {
        updateElement(element, at: index)
    }
        
    override func move(at index: Int, to newIndex: Int)
    where SourceBase.Source: RangeReplaceableCollection {
        moveElement(at: index, to: newIndex)
    }
}
