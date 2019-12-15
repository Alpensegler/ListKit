//
//  UIKitDelegates.swift
//  ListKit
//
//  Created by Frain on 2019/12/15.
//

import Foundation

class Delegates: NSObject {
    #if os(iOS) || os(tvOS)
    var scrollViewDelegates = UIScrollViewDelegates()
    var collectionViewDelegates = UICollectionViewDelegates()
    var tableViewDelegates = UITableViewDelegates()
    #endif
    var baseCoordinator: BaseCoordinator { fatalError() }
    
    lazy var selectorSets = initialSelectorSets()
    
    //Responding
    func apply<Object: AnyObject, Input, Output>(
        _ keyPath: KeyPath<Delegates, Delegate<Object, Input, Output>>,
        object: Object,
        with input: Input
    ) -> Output {
        self[keyPath: keyPath].closure!(object, input)
    }
    
    func apply<Object: AnyObject, Input>(
        _ keyPath: KeyPath<Delegates, Delegate<Object, Input, Void>>,
        object: Object,
        with input: Input
    ) {
        self[keyPath: keyPath].closure?(object, input)
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        if aSelector.map(selectorSets.contains) == true { return false }
        return super.responds(to: aSelector)
    }
}

extension Delegates {
    func apply<Object: AnyObject, Output>(
        _ keyPath: KeyPath<Delegates, Delegate<Object, Void, Output>>,
        object: Object
    ) -> Output {
        apply(keyPath, object: object, with: ())
    }
    
    func apply<Object: AnyObject>(
        _ keyPath: KeyPath<Delegates, Delegate<Object, Void, Void>>,
        object: Object
    ) {
        apply(keyPath, object: object, with: ())
    }
    
    func initialSelectorSets(withoutIndex: Bool = false) -> SelectorSets {
        var selectorSets = SelectorSets()
        selectorSets.withoutIndex = withoutIndex
        
        #if os(iOS) || os(tvOS)
        scrollViewDelegates.add(by: &selectorSets)
        collectionViewDelegates.add(by: &selectorSets)
        tableViewDelegates.add(by: &selectorSets)
        #endif
        
        return selectorSets
    }
}
