//
//  CoordinatorDifference.swift
//  ListKit
//
//  Created by Frain on 2020/5/14.
//

import Foundation

class CoordinatorDifference {
    typealias Unique<T> = [AnyHashable: T?]
    typealias UniqueChange<T> = Mapping<Unique<T>>
    
    class Context {
        lazy var uniqueChange: UniqueChange<Any> = ([:], [:])
        lazy var unhandled = [CoordinatorDifference]()
    }
    
    enum Order: CaseIterable {
        case first, second, third
    }
    
    enum ChangeState: Equatable {
        case change(moveAndRelod: Bool?)
        case reload
        case none
    }

    enum Updates {
        case insertAll
        case removeAll
        case reloadAll
        case batchUpdates(ListUpdates)
    }
    
    class Element<Value, Related>: CustomDebugStringConvertible {
        var index: Int
        var valueRelated: ValueRelated<Value, Related>
        var state = ChangeState.none
        var sectionOffset = 0
        var itemOffset = 0
        weak var associated: Element<Value, Related>? {
            didSet {
                if associated?.associated === self { return }
                associated?.associated = self
            }
        }
        
        var value: Value { valueRelated.value }
        var related: Related { valueRelated.related }
        
        var indexPath: IndexPath { IndexPath(section: sectionOffset, item: itemOffset + index) }
        var section: Int { index + sectionOffset }
        
        required init(valueRelated: ValueRelated<Value, Related>, index: Int) {
            self.valueRelated = valueRelated
            self.index = index
        }
        
        var description: String {
            "\(value), \(index), \(state)"
        }
        
        var debugDescription: String {
            associated.map { "\(description), \($0.index)" } ?? description
        }
    }
    
    var isSectioned = true
    
    lazy var updates = generateUpdates()
    
    func prepareForGenerate() { }
    func inferringMoves(context: Context) { }
    
    func prepareForGenerateUpdates() { prepareForGenerate() }
    func generateUpdates() -> Updates? {
        fatalError("should be implement by subclass")
    }
    
    func generateListUpdates(itemSources: (Int, Bool)?) -> ListUpdates {
        fatalError("should be implement by subclass")
    }
    
    func generateSourceSectionUpdate(
        order: Order,
        sectionOffset: Int = 0,
        isMoved: Bool = false
    ) -> (count: Int, update: SourceBatchUpdates?) {
        fatalError("should be implement by subclass")
    }
    
    func generateTargetSectionUpdate(
        order: Order,
        sectionOffset: Int = 0,
        isMoved: Bool = false
    ) -> (count: Int, update: TargetBatchUpdates?, change: (() -> Void)?) {
        fatalError("should be implement by subclass")
    }
    
    func generateSourceItemUpdate(
        order: Order,
        sectionOffset: Int = 0,
        itemOffset: Int = 0,
        isMoved: Bool = false
    ) -> (count: Int, update: ItemSourceUpdate?) {
        fatalError("should be implement by subclass")
    }
    
    func generateTargetItemUpdate(
        order: Order,
        sectionOffset: Int = 0,
        itemOffset: Int = 0,
        isMoved: Bool = false
    ) -> (count: Int, update: ItemTargetUpdate?, change: (() -> Void)?) {
        fatalError("should be implement by subclass")
    }
}

extension CoordinatorDifference {
    func add<Change>(
        to uniqueChanges: inout UniqueChange<Change>,
        key: AnyHashable,
        change: Change,
        isSource: Bool
    ) {
        let value: Change??
        if case .none = (isSource ? uniqueChanges.source : uniqueChanges.target)[key] {
            value = .some(change)
        } else {
            value = .some(.none)
        }
        isSource ? (uniqueChanges.source[key] = value) : (uniqueChanges.target[key] = value)
    }
    
    func applying<Change, Value, Related, Element: CoordinatorDifference.Element<Value, Related>>(
        to uniqueChanges: inout UniqueChange<Change>,
        with elements: inout Mapping<ContiguousArray<Element>>,
        id: (ValueRelated<Value, Related>) -> AnyHashable,
        equal: ((ValueRelated<Value, Related>, ValueRelated<Value, Related>) -> Bool)?,
        isAllCurrent: Bool = false,
        _ associating: ((Mapping<Element>) -> Void)? = nil,
        toChange: (Change) -> Element? = { $0 as? Element }
    ) {
        @discardableResult
        func configAssociated(for element: Element, isSource: Bool) -> Element? {
            let id = id((element.valueRelated))
            let sourceChange = uniqueChanges.source[id]?.map(toChange)
            let targetChange = uniqueChanges.target[id]?.map(toChange)
            switch (sourceChange, targetChange) {
            case let (source??, target??):
                let isEqual = equal?(source.valueRelated, target.valueRelated)
                switch (isAllCurrent, source.state, target.state) {
                case (true, _, _) where isEqual == false && source.index == target.index:
                    (source.state, target.state) = (.reload, .reload)
                case let (_, .change, .change(moveAndRelod)):
                    if isEqual != false { break }
                    guard moveAndRelod != false else { return nil }
                    target.state = .change(moveAndRelod: true)
                    source.state = .change(moveAndRelod: true)
                default:
                    return nil
                }
                source.associated = target
                associating?((source, target))
                uniqueChanges.source[id] = .some(.none)
                uniqueChanges.target[id] = .some(.none)
                return nil
            case (.some(.some), _) where isSource:
                return element
            case (_, .some(.some)) where !isSource:
                return element
            default:
                return nil
            }
        }
        
        if isAllCurrent {
            let source = elements.source.compactMapContiguous { configAssociated(for: $0, isSource: true) }
            let target = elements.target.compactMapContiguous { configAssociated(for: $0, isSource: false) }
            elements = (source, target)
        } else {
            elements.source.forEach { configAssociated(for: $0, isSource: true) }
            elements.target.forEach { configAssociated(for: $0, isSource: false) }
        }
    }
    
    func toChanges<Value, Related, Element: CoordinatorDifference.Element<Value, Related>>(
        mapping: Mapping<ContiguousArray<ValueRelated<Value, Related>>>,
        differ: Differ<ValueRelated<Value, Related>>,
        moveAndRelod: Bool? = nil,
        associating: ((Mapping<Element>) -> Void)? = nil
    ) -> (Mapping<ContiguousArray<Element>>, Mapping<ContiguousArray<Element>>) {
        var result: Mapping<ContiguousArray<Element>> = ([], [])
        var enumated: Mapping<Int> = (0, 0)
        var uniqueChanges: UniqueChange<Element> = ([:], [:])
        var changedResult: Mapping<ContiguousArray<Element>> = ([], [])
        var shouldAssociate: Bool
        var isChanged: (Bool, Int) -> Bool
        
        switch (mapping.source.isEmpty, mapping.target.isEmpty) {
        case (false, false):
            shouldAssociate = true
            let diffs = mapping.target.diff(from: mapping.source, by: differ.diffEqual)
            isChanged = { (isSource, offset) in
                let count = isSource ? enumated.source : enumated.target
                let diff = isSource ? diffs.removals : diffs.insertions
                guard count < diff.count, offset == diff[count]._offset else { return false }
                isSource ? (enumated.source += 1) : (enumated.target += 1)
                return true
            }
        case (false, true):
            isChanged = { (isSource, offset) in isSource }
            shouldAssociate = false
        case (true, false):
            isChanged = { (isSource, offset) in !isSource }
            shouldAssociate = false
        case (true, true):
            return (result, changedResult)
        }
        
        @discardableResult
        func toValue(_ arg: (Int, ValueRelated<Value, Related>), isSource: Bool) -> Element? {
            let (offset, element) = arg
            let value = Element(valueRelated: element, index: offset)
            isSource ? result.source.append(value) : result.target.append(value)
            guard isChanged(isSource, offset) else { return value }
            if let id = differ.identifier {
                isSource ? changedResult.source.append(value) : changedResult.target.append(value)
                add(to: &uniqueChanges, key: id(element), change: value, isSource: isSource)
            }
            value.state = .change(moveAndRelod: moveAndRelod)
            return nil
        }
        
        if shouldAssociate {
            let source = mapping.source.enumerated().compactMap { toValue($0, isSource: true) }
            let target = mapping.target.enumerated().compactMap { toValue($0, isSource: false) }
            
            for (source, target) in zip(source, target) {
                source.associated = target
                associating?((source, target))
            }
        } else {
            if !mapping.source.isEmpty {
                mapping.source.enumerated().forEach { toValue($0, isSource: true) }
            }
            if !mapping.target.isEmpty {
                mapping.target.enumerated().forEach { toValue($0, isSource: false) }
            }
        }
        
        if let id = differ.identifier {
            applying(
                to: &uniqueChanges,
                with: &changedResult,
                id: id,
                equal: differ.areEquivalent,
                isAllCurrent: true,
                associating
            ) { $0 }
        }
        
        
        return (result, changedResult)
    }
}

extension CoordinatorDifference {
    func generateUpdates<T>(
        for mapping: Mapping<ContiguousArray<T>>,
        reloadIfNeeded: Bool = false
    ) -> Updates? {
        generateUpdates(
            for: (mapping.source.isEmpty, mapping.target.isEmpty),
            reloadIfNeeded: reloadIfNeeded
        )
    }
    
    func generateUpdates(for mapping: Mapping<Bool>, reloadIfNeeded: Bool = false) -> Updates? {
        switch (mapping.source, mapping.target) {
        case (true, false): return .insertAll
        case (false, true): return .removeAll
        case (_, _) where reloadIfNeeded: return .reloadAll
        case (true, true): return nil
        case (false, false): break
        }
        
        prepareForGenerateUpdates()
        
        let batchUpdates: ListUpdates
        if isSectioned {
            batchUpdates = Order.allCases.compactMap { order in
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
        } else {
            batchUpdates = Order.allCases.compactMap { order in
                let source = generateSourceItemUpdate(order: order)
                let target = generateTargetItemUpdate(order: order)
                guard source.update != nil || target.update != nil else { return nil }
                var itemUpdate = ItemUpdate()
                source.update.map { itemUpdate.source = $0 }
                target.update.map { itemUpdate.target = $0 }
                return (itemUpdate, target.change)
            }
        }
        return batchUpdates.isEmpty ? nil : .batchUpdates(batchUpdates)
    }
}
