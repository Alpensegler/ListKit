//
//  WrapperCoordinatorContext.swift
//  ListKit
//
//  Created by Frain on 2020/6/8.
//

import Foundation

class WrapperCoordinatorContext<SourceBase, Other>: ListCoordinatorContext<SourceBase>
where SourceBase: DataSource, SourceBase.SourceBase == SourceBase, Other: DataSource {
    var coordinator: WrapperCoordinator<SourceBase, Other>
    
    lazy var finalSelectorSets = configSelectedSet()
    var wrapped: ListCoordinatorContext<Other.SourceBase>? { coordinator.wrapped?.context }
    
    override var selectorSets: SelectorSets { finalSelectorSets }
    
    init(
        _ coordinator: WrapperCoordinator<SourceBase, Other>,
        setups: [(ListCoordinatorContext<SourceBase>) -> Void]
    ) {
        self.coordinator = coordinator
        super.init(coordinator, setups: setups)
    }
    
    func configSelectedSet() -> SelectorSets {
        wrapped.map { SelectorSets(merging: selfSelectorSets, $0.selectorSets) } ?? selfSelectorSets
    }
    
    func subcontext(for selector: Selector) -> CoordinatorContext? {
        wrapped?.selectorSets.contains(selector) == true ? wrapped : nil
    }
    
    override func reconfig() {
        finalSelectorSets = configSelectedSet()
        resetDelegates?()
    }
    
    // Selectors
    override func apply<Object: AnyObject, Input, Output>(
        _ keyPath: KeyPath<CoordinatorContext, Delegate<Object, Input, Output>>,
        root: CoordinatorContext,
        object: Object,
        with input: Input
    ) -> Output {
        let context = subcontext(for: self[keyPath: keyPath].selector)
        return context?.apply(keyPath, root: root, object: object, with: input)
            ?? super.apply(keyPath, root: root, object: object, with: input)
    }
    
    override func apply<Object: AnyObject, Input>(
        _ keyPath: KeyPath<CoordinatorContext, Delegate<Object, Input, Void>>,
        root: CoordinatorContext,
        object: Object,
        with input: Input
    ) {
        let context = subcontext(for: self[keyPath: keyPath].selector)
        context?.apply(keyPath, root: root, object: object, with: input)
        super.apply(keyPath, root: root, object: object, with: input)
    }
    
    override func apply<Object: AnyObject, Input, Output, Index>(
        _ keyPath: KeyPath<CoordinatorContext, IndexDelegate<Object, Input, Output, Index>>,
        root: CoordinatorContext,
        object: Object,
        with input: Input,
        _ offset: Index
    ) -> Output? {
        let context = subcontext(for: self[keyPath: keyPath].selector)
        return context?.apply(keyPath, root: root, object: object, with: input, offset)
            ?? super.apply(keyPath, root: root, object: object, with: input, offset)
    }
    
    override func apply<Object: AnyObject, Input, Index>(
        _ keyPath: KeyPath<CoordinatorContext, IndexDelegate<Object, Input, Void, Index>>,
        root: CoordinatorContext,
        object: Object,
        with input: Input,
        _ offset: Index
    ) {
        let context = subcontext(for: self[keyPath: keyPath].selector)
        context?.apply(keyPath, root: root, object: object, with: input, offset)
        super.apply(keyPath, root: root, object: object, with: input, offset)
    }
}
