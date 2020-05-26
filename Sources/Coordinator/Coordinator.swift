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

final class ListContext {
    weak var parentCoordinator: Coordinator?
    var sectionOffset: Int
    var itemOffset: Int
    var listView: () -> ListView?
    
    init(sectionOffset: Int = 0, itemOffset: Int = 0, listView: @escaping () -> ListView?) {
        self.sectionOffset = sectionOffset
        self.itemOffset = itemOffset
        self.listView = listView
    }
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
    
    //Diff
    func difference<Value>(from: Coordinator, differ: Differ<Value>?) -> CoordinatorDifference?
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
