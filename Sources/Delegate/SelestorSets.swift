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
    
    func contains(_ selector: Selector) -> Bool {
        withIndexPath.contains(selector)
            || void.contains(selector)
            || value.contains(selector)
            || withIndex.contains(selector)
    }
    
    func add<Input, Object, Output>(
        _ closureDelegate: Delegate<Object, Input, Output>
    ) {
        switch (closureDelegate.index, withoutIndex) {
        case (.none, _): value.insert(closureDelegate.selector)
        case (.indexPath, false): withIndexPath.insert(closureDelegate.selector)
        case (.index, false):
            withIndex.insert(closureDelegate.selector)
            hasIndex = true
        default: break
        }
    }
    
    func add<Input, Object>(_ closureDelegate: Delegate<Object, Input, Void>) {
        void.insert(closureDelegate.selector)
        if case .index = closureDelegate.index { hasIndex = true }
    }
}
