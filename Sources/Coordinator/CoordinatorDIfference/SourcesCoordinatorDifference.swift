//
//  SourcesCoordinatorDifference.swift
//  ListKit
//
//  Created by Frain on 2020/5/15.
//

import Foundation

final class SourcesCoordinatorDifference<Element: DataSource>: CoordinatorDifference {
    typealias Value = SourcesSubelement<Element>
    typealias Related = SourcesContext<Element.SourceBase>
    typealias MapValue = (value: Value, related: Related)
    typealias Item = Element.SourceBase.Item
    
    final class DataSourceElement: CoordinatorDifference.Element<Value, Related> {
        var difference: CoordinatorDifference?
    }
    
    let mapping: Mapping<[MapValue]>
    let differ: Differ<MapValue>
    let itemDiffer: Differ<Item>?
    
    var isSectioned = false
    var extraCoordinatorChange: (([MapValue]) -> Void)?
    var coordinatorChange: (() -> Void)?
    var updateIndices: (() -> Void)?
    
    var changes: Mapping<[DataSourceElement]> = ([], [])
    var uniques: Mapping<[DataSourceElement]> = ([], [])
    
    var unhandled = [CoordinatorDifference]()
    
    var needExtraUpdate = false
    var differences = [CoordinatorDifference]()
    
    lazy var extraSources = [MapValue]()
    
    init(mapping: Mapping<[MapValue]>, itemDiffer: Differ<Item>?) {
        self.mapping = mapping
        self.itemDiffer = itemDiffer
        let identifier = { (arg: MapValue) -> AnyHashable in
            switch arg.value {
            case .element(let element):
                return HashCombiner(0, arg.related.coordinator.identifier(for: element.sourceBase))
            case .items(let id, _):
                return HashCombiner(1, id)
            }
        }
        let euqal = { (lhs: MapValue, rhs: MapValue) -> Bool in
            let related = lhs.related
            switch (lhs.value, rhs.value) {
            case let (.element(lhs), .element(rhs)):
                return related.coordinator.equal(lhs: lhs.sourceBase, rhs: rhs.sourceBase)
            case let (.items(lhs, _), .items(rhs, _)):
                return lhs == rhs
            default:
                return false
            }
        }
        self.differ = .init(identifier: identifier, areEquivalent: euqal) { (lhs, rhs) in
            guard identifier(lhs) == identifier(rhs) else { return false }
            return euqal(lhs, rhs)
        }
        super.init()
    }
    
    func associating(source: DataSourceElement, target: DataSourceElement) {
        guard source.state != .change(moveAndRelod: true), source.state != .reload else { return }
        let toCoordinator = target.related.coordinator
        let fromCoordinator = source.related.coordinator
        if let difference = toCoordinator.difference(from: fromCoordinator, differ: itemDiffer) {
            source.difference = difference
            target.difference = difference
            unhandled.append(difference)
        } else {
            if case .change = source.state {
                target.state = .change(moveAndRelod: true)
                source.state = .change(moveAndRelod: true)
            } else {
                (source.state, target.state) = (.reload, .reload)
            }
        }
    }
    
    override func prepareForGenerate() {
        (changes, uniques) = toChanges(mapping: mapping, differ: differ, associating: associating)
    }
    
    override func inferringMoves(context: Context) {
        guard let id = differ.identifier else { return }
        uniques.source.forEach {
            add(to: &context.uniqueChange, key: id($0.asTuple), change: $0, isSource: true)
        }
        uniques.target.forEach {
            add(to: &context.uniqueChange, key: id($0.asTuple), change: $0, isSource: false)
        }
        
        let equal = differ.areEquivalent
        applying(to: &context.uniqueChange, with: &uniques, id: id, equal: equal, associating)
        
        context.unhandled += unhandled
    }
    
    override func generateUpdates() -> Updates? {
        switch (mapping.source.isEmpty, mapping.target.isEmpty) {
        case (false, false):
            prepareForGenerate()
            let context = Context()
            inferringMoves(context: context)
            while !context.unhandled.isEmpty {
                context.unhandled.forEach {
                    $0.prepareForGenerate()
                    $0.inferringMoves(context: context)
                }
                context.unhandled.removeAll()
            }
            
            let batchUpdates: ListUpdates = Order.allCases.compactMap { order in
                let source = generateSourceSectionUpdate(order: order)
                let target = generateTargetSectionUpdate(order: order)
                guard source.update != nil || target.update != nil else { return nil }
                var batchUpdate = ListBatchUpdates()
                source.update.map {
                    batchUpdate.section.source = $0.section
                    batchUpdate.item.source = $0.item
                }
                target.update.map {
                    batchUpdate.section.target = $0.section
                    batchUpdate.item.target = $0.item
                }
                return (batchUpdate, target.change)
            }
            return batchUpdates.isEmpty ? nil : .batchUpdates(batchUpdates)
        case (true, false):
            return .insertAll
        case (false, true):
            return .removeAll
        case (true, true):
            return nil
        }
    }
    
    override func generateListUpdates(itemSources: (Int, Bool)?) -> ListUpdates {
        guard let update = updates else { return [] }
        switch update {
        case .batchUpdates(let batchUpdates):
            return batchUpdates
        case .insertAll:
            let indexSet = IndexSet(integersIn: 0..<mapping.target.count)
            let section = SectionUpdate(target: .init(insertions: indexSet))
            return [(ListBatchUpdates(section: section), coordinatorChange)]
        case .removeAll:
            let indexSet = IndexSet(integersIn: 0..<mapping.source.count)
            let section = SectionUpdate(source: .init(deletions: indexSet))
            return [(ListBatchUpdates(section: section), coordinatorChange)]
        }
    }
    
    override func generateSourceSectionUpdate(
        order: Order,
        sectionOffset: Int = 0,
        isMoved: Bool = false
    ) -> (count: Int, update: SourceBatchUpdates?) {
        var sectionCount = 0
        var update = SourceBatchUpdates()
        var section: Int { sectionCount + sectionOffset }
        
        func addToUpdate(_ element: DataSourceElement, isMoved move: Bool) {
            guard let difference = element.difference else {
                sectionCount += element.related.coordinator.numbersOfSections()
                return
            }
            let (count, subupdate) = difference.generateSourceSectionUpdate(
                order: order,
                sectionOffset: section,
                isMoved: move || isMoved
            )
            sectionCount += count
            subupdate.map { update.add(other: $0) }
        }
        
        func reload(from coordinator: Coordinator, to other: Coordinator) {
            let from = coordinator.numbersOfSections()
            let to = other.numbersOfSections()
            let diff = from - to
            sectionCount += from
            guard diff > 0 else { return }
            update.section.deletions.insert(integersIn: section + from - diff..<section + from)
        }
        
        switch order {
        case .first:
            for element in changes.source {
                element.sectionOffset = section
                switch (element.state, element.associated) {
                case (.reload, .some):
                    if isMoved { needExtraUpdate = true }
                    sectionCount += element.related.coordinator.numbersOfSections()
                case let (.change(moveAndReload), .some):
                    if moveAndReload == true {
                        needExtraUpdate = true
                        sectionCount += element.related.coordinator.numbersOfSections()
                    } else {
                        addToUpdate(element, isMoved: true)
                    }
                case (.change, .none):
                    let count = element.related.coordinator.numbersOfSections()
                    guard count != 0 else { continue }
                    let range = section..<section + count
                    update.section.deletions.insert(integersIn: range)
                    sectionCount += count
                default:
                    addToUpdate(element, isMoved: false)
                }
            }
        case .second where needExtraUpdate:
            for element in changes.target {
                switch (element.state, element.associated) {
                case (.reload, let associated?) where isMoved:
                    reload(from: associated.related.coordinator, to: element.related.coordinator)
                case (.change(true), let associated?):
                    reload(from: associated.related.coordinator, to: element.related.coordinator)
                default:
                    addToUpdate(element, isMoved: false)
                }
            }
        default:
            changes.target.forEach { addToUpdate($0, isMoved: false) }
        }
        return (sectionCount, update)
    }
    
    override func generateTargetSectionUpdate(
        order: Order,
        sectionOffset: Int = 0,
        isMoved: Bool = false
    ) -> (count: Int, update: TargetBatchUpdates?, change: (() -> Void)?) {
        var sectionCount = 0
        var update = TargetBatchUpdates()
        var change: (() -> Void)?
        var section: Int { sectionCount + sectionOffset }
        
        func addToUpdate(_ element: DataSourceElement, isMoved move: Bool) {
            guard let difference = element.difference else {
                sectionCount += element.related.coordinator.numbersOfSections()
                return
            }
            let (count, subupdate, subchange) = difference.generateTargetSectionUpdate(
                order: order,
                sectionOffset: section,
                isMoved: move || isMoved
            )
            sectionCount += count
            subupdate.map { update.add(other: $0) }
            change = change + subchange
        }
        
        func reload(from coordinator: Coordinator, to other: Coordinator) {
            let from = coordinator.numbersOfSections()
            let to = other.numbersOfSections()
            let diff = to - from
            sectionCount += to
            let minValue = min(from, to)
            if minValue != 0 {
                update.section.updates.insert(integersIn: section..<section + minValue)
            }
            if diff > 0 {
                update.section.insertions.insert(integersIn: section + to - diff..<section + to)
            }
        }
        
        func move(from associated: CoordinatorDifference.Element<Value, Related>) {
            let count = associated.related.coordinator.numbersOfSections()
            sectionCount += count
            if count == 0 { return }
            for i in 0..<count {
                update.section.moves.append((associated.index + i, section + i))
            }
        }
        
        switch order {
        case .first:
            for element in changes.target {
                element.sectionOffset = section
                switch (element.state, element.associated) {
                case let (.change(moveAndReload), associated?):
                    if moveAndReload == true {
                        move(from: associated)
                        if needExtraUpdate { extraSources.append(associated.asTuple) }
                    } else {
                        addToUpdate(element, isMoved: true)
                        if needExtraUpdate { extraSources.append(element.asTuple) }
                    }
                case let (.reload, associated?):
                    if isMoved {
                        move(from: associated)
                        if needExtraUpdate { extraSources.append(associated.asTuple) }
                    } else {
                        reload(from: associated.related.coordinator, to: element.related.coordinator)
                        if needExtraUpdate { extraSources.append(element.asTuple) }
                    }
                case (_, .some):
                    addToUpdate(element, isMoved: isMoved)
                    if needExtraUpdate { extraSources.append(element.asTuple) }
                default:
                    let count = element.related.coordinator.numbersOfSections()
                    if count == 0 { continue }
                    update.section.insertions.insert(integersIn: section..<section + count)
                    sectionCount += count
                }
            }
            if needExtraUpdate {
                change = change + extraCoordinatorChange.map { change in
                    { change(self.extraSources) }
                } + updateIndices
            } else {
                change = change + coordinatorChange + updateIndices
            }
        case .second where needExtraUpdate:
            for element in changes.target {
                switch (element.state, element.associated) {
                case (.reload, let associated?) where isMoved:
                    reload(from: associated.related.coordinator, to: element.related.coordinator)
                case (.change(true), let associated?):
                    reload(from: associated.related.coordinator, to: element.related.coordinator)
                default:
                    addToUpdate(element, isMoved: false)
                }
            }
            change = change + coordinatorChange + updateIndices
        default:
            changes.target.forEach { addToUpdate($0, isMoved: false) }
            change = change + updateIndices
        }
        
        return (sectionCount, update, change)
    }
}
