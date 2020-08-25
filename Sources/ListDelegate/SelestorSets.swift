//
//  SelestorSets.swift
//  ListKit
//
//  Created by Frain on 2019/12/15.
//

import Foundation

struct SelectorSets {
    var void = Set<Selector>()
    var value = Set<Selector>()
    var withIndex = Set<Selector>()
    var withIndexPath = Set<Selector>()
    var hasIndex: Bool { !withIndex.isEmpty }
}

extension SelectorSets {
    init(merging lhs: SelectorSets, _ rhs: SelectorSets) {
        self.void = lhs.void.union(rhs.void)
        self.value = lhs.value.union(rhs.value)
        self.withIndex = lhs.withIndex.union(rhs.withIndex)
        self.withIndexPath = lhs.withIndexPath.union(rhs.withIndexPath)
    }
    
    func contains(_ selector: Selector) -> Bool {
        withIndexPath.contains(selector)
            || void.contains(selector)
            || value.contains(selector)
            || withIndex.contains(selector)
    }
    
    mutating func add<Input, Object, Output, Index>(
        _ delegate: IndexDelegate<Object, Input, Output, Index>
    ) {
        if Index.isSection {
            withIndex.insert(delegate.selector)
        } else {
            withIndexPath.insert(delegate.selector)
        }
    }
    
    mutating func add<Input, Output, Object>(_ delegate: Delegate<Object, Input, Output>) {
        value.insert(delegate.selector)
    }
    
    mutating func add<Input, Object>(_ delegate: Delegate<Object, Input, Void>) {
        void.insert(delegate.selector)
    }
}
