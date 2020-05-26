//
//  SourcesCoordinatorDifference.swift
//  ListKit
//
//  Created by Frain on 2020/5/15.
//

import Foundation

final class SourcesCoordinatorDifference<Element: DataSource>: CoordinatorDifference {
    typealias Coordinator = ListCoordinator<Element.SourceBase>
    typealias Value = SourcesSubelement<Element>
    typealias MapValue = (value: Value, related: Coordinator)
    typealias Item = Element.SourceBase.Item
    
    final class DataSourceElement: CoordinatorDifference.Element<Value, Coordinator> {
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
                return HashCombiner(0, arg.related.identifier(for: element.sourceBase))
            case .items(let id, _):
                return HashCombiner(1, id)
            }
        }
        let euqal = { (lhs: MapValue, rhs: MapValue) -> Bool in
            let related = lhs.related
            switch (lhs.value, rhs.value) {
            case let (.element(lhs), .element(rhs)):
                return related.equal(lhs: lhs.sourceBase, rhs: rhs.sourceBase)
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
        if let difference = target.related.difference(from: source.related, differ: itemDiffer) {
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
                sectionCount += element.related.numbersOfSections()
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
                    sectionCount += element.related.numbersOfSections()
                case let (.change(moveAndReload), .some):
                    if moveAndReload == true {
                        needExtraUpdate = true
                        sectionCount += element.related.numbersOfSections()
                    } else {
                        addToUpdate(element, isMoved: true)
                    }
                case (.change, .none):
                    let count = element.related.numbersOfSections()
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
                    reload(from: associated.related, to: element.related)
                case (.change(true), let associated?):
                    reload(from: associated.related, to: element.related)
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
                sectionCount += element.related.numbersOfSections()
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
        
        func move(from associated: CoordinatorDifference.Element<Value, Coordinator>) {
            let count = associated.related.numbersOfSections()
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
                        reload(from: associated.related, to: element.related)
                        if needExtraUpdate { extraSources.append(element.asTuple) }
                    }
                case (_, .some):
                    addToUpdate(element, isMoved: isMoved)
                    if needExtraUpdate { extraSources.append(element.asTuple) }
                default:
                    let count = element.related.numbersOfSections()
                    if count == 0 { continue }
                    update.section.insertions.insert(integersIn: section..<section + count)
                    sectionCount += count
                }
            }
            if needExtraUpdate {
                change = change + extraCoordinatorChange.map { change in
                    { change(self.extraSources) }
                }
            } else {
                change = change + coordinatorChange
            }
        case .second where needExtraUpdate:
            for element in changes.target {
                switch (element.state, element.associated) {
                case (.reload, let associated?) where isMoved:
                    reload(from: associated.related, to: element.related)
                case (.change(true), let associated?):
                    reload(from: associated.related, to: element.related)
                default:
                    addToUpdate(element, isMoved: false)
                }
            }
            change = change + coordinatorChange
        default:
            changes.target.forEach { addToUpdate($0, isMoved: false) }
            change = change + updateIndices
        }
        
        return (sectionCount, update, change)
    }
}
