//
//  ClosureDelegate.swift
//  ListKit
//
//  Created by Frain on 2019/12/9.
//

import Foundation
import ObjectiveC.runtime

struct Delegate<Object: AnyObject, Input, Output> {
    enum Index {
        case index(KeyPath<Input, Int>)
        case indexPath(KeyPath<Input, IndexPath>)
    }
    
    let selector: Selector
    let index: Index?
    var closure: ((Object, Input) -> Output)?
    
    init(index: Index? = nil, _ selector: Selector) {
        self.index = index
        self.selector = selector
        self.closure = nil
    }
}

struct SelectorSets {
    var void = Set<Selector>()
    var value = Set<Selector>()
    var withIndex = Set<Selector>()
    var withIndexPath = Set<Selector>()
    
    func contains(_ selector: Selector) -> Bool {
        withIndexPath.contains(selector)
            || void.contains(selector)
            || value.contains(selector)
            || withIndex.contains(selector)
    }
    
    mutating func add<Input, Object, Output>(
        _ closureDelegate: Delegate<Object, Input, Output>
    ) {
        switch (closureDelegate.index) {
        case (.none): value.insert(closureDelegate.selector)
        case (.index): withIndex.insert(closureDelegate.selector)
        case (.indexPath): withIndexPath.insert(closureDelegate.selector)
        }
    }
    
    mutating func add<Input, Object>(_ closureDelegate: Delegate<Object, Input, Void>) {
        void.insert(closureDelegate.selector)
    }
}
