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
        lazy var unhandled: Mapping<[Coordinator]> = ([], [])
        lazy var unhandledMoved = [HashCombiner: Mapping<Coordinator?>]()
        lazy var updates = [ObjectIdentifier: ListUpdate]()
    }
    
    enum ChangeState {
        case change(moveAndRelod: Bool?)
        case reload
        case none
    }
    
    class Element<Value, Related> {
        var index: Int
        var value: Value
        var related: Related
        var state = ChangeState.none
        var asTuple: (Value, Related) { (value, related) }
        
        var associated: Element<Value, Related>? {
            didSet {
                if associated?.associated === self { return }
                associated?.associated = self
            }
        }
        
        required init(value: Value, related: Related, index: Int) {
            self.value = value
            self.related = related
            self.index = index
        }
    }
    
    func prepareForGenerate() { }
    func prepareForGenerate(context: Context) { }
    
    func generateUpdate(isSectioned: Bool, isMoved: Bool) -> ListUpdate {
        fatalError("should be implement by subclass")
    }
    
    func generateUpdate() -> ListUpdate {
        prepareForGenerate()
        return generateUpdate(isSectioned: true, isMoved: false)
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
        with elements: inout Mapping<[Element]>,
        id: ((value: Value, related: Related)) -> AnyHashable,
        differ: Differ<(value: Value, related: Related)>,
        isAllCurrent: Bool = false,
        associating: ((Mapping<Element>) -> Void)? = nil,
        toChange: (Change) -> Element? = { $0 as? Element }
    ) {
        @discardableResult
        func configAssociated(for element: Element, isSource: Bool) -> Element? {
            let id = id((element.value, element.related))
            let sourceChange = uniqueChanges.source[id]?.map(toChange)
            let targetChange = uniqueChanges.target[id]?.map(toChange)
            switch (sourceChange, targetChange) {
            case let (source??, target??):
                switch (isAllCurrent, source.state, target.state) {
                case (true, _, _) where source.index == target.index:
                    (source.state, target.state) = (.reload, .reload)
                case let (_, .change, .change(moveAndRelod)):
                    if differ.equal(lhs: source.asTuple, rhs: target.asTuple) { break }
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
            let source = elements.source.compactMap { configAssociated(for: $0, isSource: true) }
            let target = elements.target.compactMap { configAssociated(for: $0, isSource: false) }
            elements = (source, target)
        } else {
            elements.source.forEach { configAssociated(for: $0, isSource: true) }
            elements.target.forEach { configAssociated(for: $0, isSource: false) }
        }
    }
    
    func toChanges<Value, Related, Element: CoordinatorDifference.Element<Value, Related>>(
        mapping: Mapping<[(value: Value, related: Related)]>,
        differ: Differ<(value: Value, related: Related)>,
        moveAndRelod: Bool? = nil,
        associating: ((Mapping<Element>) -> Void)? = nil
    ) -> (Mapping<[Element]>, Mapping<[Element]>) {
        var result: Mapping<[Element]> = ([], [])
        var enumated: Mapping<Int> = (0, 0)
        var uniqueChanges: UniqueChange<Element> = ([:], [:])
        var changedResult: Mapping<[Element]> = ([], [])
        
        let diffs = mapping.target.diff(from: mapping.target, by: differ.diffEqual)
        
        func toValue(_ arg: (Int, (value: Value, related: Related)), isSource: Bool) -> Element? {
            let (offset, element) = arg
            let value = Element(value: element.value, related: element.related, index: offset)
            isSource ? result.source.append(value) : result.target.append(value)
            let enumatedCount = isSource ? enumated.source : enumated.target
            let diffValue = isSource ? diffs.removals : diffs.insertions
            guard enumatedCount < diffValue.count, offset == diffValue[enumatedCount]._offset else {
                return value
            }
            isSource ? (enumated.source += 1) : (enumated.target += 1)
            if let id = differ.identifier {
                isSource ? changedResult.source.append(value) : changedResult.target.append(value)
                add(to: &uniqueChanges, key: id(element), change: value, isSource: isSource)
            }
            value.state = .change(moveAndRelod: moveAndRelod)
            return nil
        }
        
        let source = mapping.source.enumerated().lazy.compactMap { toValue($0, isSource: true) }
        let target = mapping.target.enumerated().lazy.compactMap { toValue($0, isSource: false) }
        
        for (source, target) in zip(source, target) {
            source.associated = target
            associating?((source, target))
        }
        
        if let id = differ.identifier {
            applying(
                to: &uniqueChanges,
                with: &changedResult,
                id: id,
                differ: differ,
                isAllCurrent: true,
                associating: associating
            ) { $0 }
        }
        
        
        return (result, changedResult)
    }
}
