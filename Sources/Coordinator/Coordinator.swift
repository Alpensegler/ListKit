//
//  BaseCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/10/12.
//

import Foundation

enum SourceType {
    case cell, section
}

enum SourceMultipleType {
    case single, multiple, sources, noneDiffable
}

enum ListContextType {
    case listView(ListView?)
    case superContext(Int, Int, [ListContext])
}

protocol ListContext: AnyObject {
    var itemSources: (Int, Bool)? { get }
    var contextType: ListContextType { get }
}

protocol Coordinator: AnyObject {
    var selectorSets: SelectorSets { get }
    var didSetup: Bool { get set }
    
    #if os(iOS) || os(tvOS)
    var scrollListDelegate: UIScrollListDelegate { get set }
    var collectionListDelegate: UICollectionListDelegate { get set }
    var tableListDelegate: UITableListDelegate { get set }
    #endif
    
    func numbersOfSections() -> Int
    func numbersOfItems(in section: Int) -> Int
    
    func apply<Object: AnyObject, Input, Output>(
        _ keyPath: KeyPath<Coordinator, Delegate<Object, Input, Output>>,
        object: Object,
        with input: Input,
        _ sectionOffset: Int,
        _ itemOffset: Int
    ) -> Output
    
    func apply<Object: AnyObject, Input>(
        _ keyPath: KeyPath<Coordinator, Delegate<Object, Input, Void>>,
        object: Object,
        with input: Input,
        _ sectionOffset: Int,
        _ itemOffset: Int
    )
    
    func setup()
    func setupContext(listContext: ListContext)
    func removeContext(listContext: ListContext)
}

extension ListContext {
    var itemSources: (Int, Bool)? { nil }
    
    func contexts(
        sectionOffset: Int = 0,
        itemOffset: Int = 0,
        sectionRootContext: ListContext? = nil
    ) -> [(Int, Int, ListView, ListContext?)] {
        var contexts = [(Int, Int, ListView, ListContext?)]()
        switch contextType {
        case let .listView(listView):
            guard let listView = listView else { break }
            contexts.append((sectionOffset, itemOffset, listView, sectionRootContext))
        case let .superContext(section, item, values):
            let rootContext = itemSources != nil ? self : (sectionRootContext ?? self)
            contexts += values.flatMap {
                $0.contexts(
                    sectionOffset: sectionOffset + section,
                    itemOffset: itemOffset + item,
                    sectionRootContext: rootContext
                )
            }
        }
        return contexts
    }
}

extension Coordinator {
    func apply<Object: AnyObject, Input, Output>(
        _ keyPath: KeyPath<Coordinator, Delegate<Object, Input, Output>>,
        object: Object,
        with input: Input
    ) -> Output {
        apply(keyPath, object: object, with: input, 0, 0)
    }
    
    func apply<Object: AnyObject, Input>(
        _ keyPath: KeyPath<Coordinator, Delegate<Object, Input, Void>>,
        object: Object,
        with input: Input
    ) {
        apply(keyPath, object: object, with: input, 0, 0)
    }
    
    func setupIfNeeded() {
        if didSetup { return }
        setup()
        didSetup = true
    }
    
    func initialSelectorSets(withoutIndex: Bool = false) -> SelectorSets {
        var selectorSets = SelectorSets()
        selectorSets.withoutIndex = withoutIndex
        
        #if os(iOS) || os(tvOS)
        scrollListDelegate.add(by: &selectorSets)
        collectionListDelegate.add(by: &selectorSets)
        tableListDelegate.add(by: &selectorSets)
        #endif
        
        return selectorSets
    }
}
