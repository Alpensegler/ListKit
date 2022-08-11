//
//  SectionsCoordinatorUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/7/15.
//

// swiftlint:disable opening_brace

import Foundation

class SectionsCoordinatorUpdate<SourceBase>: ContainerCoordinatorUpdate<
    SourceBase,
    ContiguousArray<Sources<SourceBase.Source.Element, SourceBase.Model>>,
    Sources<SourceBase.Source.Element, SourceBase.Model>
>
where
    SourceBase: DataSource,
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: Collection,
    SourceBase.Source.Element: Collection,
    SourceBase.Source.Element.Element == SourceBase.Model
{
    typealias Value = ListKit.Sources<SourceBase.Source.Element, SourceBase.Model>
    typealias Sections = ContiguousArray<Value>

    weak var coordinator: SectionsCoordinator<SourceBase>?

    var updateType: ModelsCoordinatorUpdate<Value>.Type { ModelsCoordinatorUpdate<Value>.self }

    override var identifiable: Bool { false }

    required init(
        coordinator: SectionsCoordinator<SourceBase>,
        update: ListUpdate<SourceBase>?,
        values: Mapping<Values>,
        sources: Sources,
        indices: Mapping<Indices>,
        options: Options
    ) {
        self.coordinator = coordinator
        super.init(coordinator, update, values, sources, indices, options)
    }

    override func toIdentifier(_ value: Value) -> ObjectIdentifier {
        ObjectIdentifier(value.listCoordinator)
    }

    override func toIndices(_ values: Values) -> Indices {
        SectionsCoordinator<SourceBase>.toIndices(values, options.target)
    }

    override func subupdate(from value: Mapping<Value>) -> Subupdate {
        let (source, target) = (value.source.listCoordinator, value.target.listCoordinator)
        return target.update(from: source, updateWay: updateWay)
    }

    override func changeWhenHasNext(values: Values, source: SourceBase.Source?, indices: Indices) {
        coordinator?.sections = values
        coordinator?.indices = indices
        coordinator?.source = source
    }

    override func toValue(_ element: Element) -> Value { element }
    override func toChange(_ value: Value, _ index: Int) -> Change {
        let change = Change(value: value, index: index, value.listCoordinator, moveAndReloadable)
        change.coordinatorUpdate = self
        return change
    }

    override func configChangesForDiffs() -> Changes {
        let (sourceCount, targetCount) = (sourceValues.count, targetValues.count)
        let diff = sourceCount - targetCount, minCount = min(sourceCount, targetCount)
        if diff == 0 { return (.init(), .init()) }
        let values = diff > 0 ? sourceValues : targetValues
        let changes = (minCount..<minCount + abs(diff)).mapContiguous { toChange(values[$0], $0) }
        return (diff > 0) ? (changes, .init()) : (.init(), changes)
    }

    override func updateData(_ isSource: Bool, containsSubupdate: Bool) {
        super.updateData(isSource, containsSubupdate: containsSubupdate)
        coordinator?.sections = isSource ? sourceValues : targetValues
        coordinator?.indices = isSource ? sourceIndices : targetIndices
    }

    override func inferringMoves(context: Context? = nil, ids: [AnyHashable] = []) {
        guard differ.identifier != nil else { return }
        super.inferringMoves(context: context)
    }

    override func customUpdateWay() -> UpdateWay? {
        if isBatchUpdate { return .batch }
        guard differ?.isNone == false else { return .other(.reload) }
        return .batch
    }

    override func generateSourceUpdate(
        order: Order,
        context: UpdateContext<Int> = (nil, false, [])
    ) -> UpdateSource<BatchUpdates.ListSource> {
        sourceUpdate(order, in: context, \.section, Subupdate.generateContianerSourceUpdate)
    }

    override func generateTargetUpdate(
        order: Order,
        context: UpdateContext<Offset<Int>> = (nil, false, [])
    ) -> UpdateTarget<BatchUpdates.ListTarget> {
        targetUpdate(order, in: context, \.section, Subupdate.generateContianerTargetUpdate)
    }
}

final class RangeReplacableSectionsCoordinatorUpdate<SourceBase>: SectionsCoordinatorUpdate<SourceBase>
where
    SourceBase: DataSource,
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: RangeReplaceableCollection,
    SourceBase.Source.Element.Element == SourceBase.Model
{
    override var moveAndReloadable: Bool { !noneDiffUpdate }

    override var updateType: ModelsCoordinatorUpdate<Value>.Type {
        RangeReplacableModelsCoordinatorUpdate<Value>.self
    }

    override func toSource(_ values: ContiguousArray<Value>) -> SourceBase.Source? {
        .init(values.map { $0.source })
    }
}
