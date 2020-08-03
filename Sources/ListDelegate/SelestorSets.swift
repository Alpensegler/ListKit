//
//  SelestorSets.swift
//  ListKit
//
//  Created by Frain on 2019/12/15.
//

import Foundation

class SelectorSets {
    var void = Set<Selector>()
    var value = Set<Selector>()
    var withIndex = Set<Selector>()
    var withIndexPath = Set<Selector>()
    var withoutIndex = false
    var hasIndex = false
    
    init(
        void: Set<Selector> = .init(),
        value: Set<Selector> = .init(),
        withIndex: Set<Selector> = .init(),
        withIndexPath: Set<Selector> = .init(),
        withoutIndex: Bool = false,
        hasIndex: Bool = false
    ) {
        self.void = void
        self.value = value
        self.withIndex = withIndex
        self.withIndexPath = withIndexPath
        self.withoutIndex = withoutIndex
        self.hasIndex = hasIndex
    }
    
    init(merging lhs: SelectorSets, _ rhs: SelectorSets) {
        self.void = lhs.void.intersection(rhs.void)
        self.value = lhs.value.intersection(rhs.value)
        self.withIndex = lhs.withIndex.intersection(rhs.withIndex)
        self.withIndexPath = lhs.withIndexPath.intersection(rhs.withIndexPath)
        self.withoutIndex = lhs.withoutIndex || rhs.withoutIndex
        self.hasIndex = lhs.hasIndex || rhs.hasIndex
    }
    
    func contains(_ selector: Selector) -> Bool {
        withIndexPath.contains(selector)
            || void.contains(selector)
            || value.contains(selector)
            || withIndex.contains(selector)
    }
    
    func add<Input, Object, Output, Index>(
        _ closureDelegate: Delegate<Object, Input, Output, Index>
    ) {
        if closureDelegate.index == nil {
            value.insert(closureDelegate.selector)
        } else if Index.self == IndexPath.self, !withoutIndex {
            withIndexPath.insert(closureDelegate.selector)
        } else if Index.self == Int.self, !withoutIndex {
            withIndex.insert(closureDelegate.selector)
        }
    }
    
    func add<Input, Object, Index>(_ closureDelegate: Delegate<Object, Input, Void, Index>) {
        void.insert(closureDelegate.selector)
    }
}
