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
        with input: Input
    ) -> Output
    
    func apply<Object: AnyObject, Input>(
        _ keyPath: KeyPath<Coordinator, Delegate<Object, Input, Void>>,
        object: Object,
        with input: Input
    )
    
    func setup()
    
    func setupContext(
        listView: ListView,
        key: ObjectIdentifier,
        sectionOffset: Int,
        itemOffset: Int,
        supercoordinator: Coordinator?
    )
    
    func update(
        from coordinator: Coordinator,
        animated: Bool,
        completion: ((Bool) -> Void)?
    ) -> Bool
    
    //Diff
    func difference<Value>(from: Coordinator, differ: Differ<Value>?) -> CoordinatorDifference?
}

extension Coordinator {
    func setupIfNeeded() {
        if didSetup { return }
        setup()
        didSetup = true
    }
    
    func setup(listView: ListView, key: ObjectIdentifier) {
        setupIfNeeded()
        setupContext(
            listView: listView,
            key: key,
            sectionOffset: 0,
            itemOffset: 0,
            supercoordinator: nil
        )
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
