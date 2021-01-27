//
//  WrapperCoordinatorContext.swift
//  ListKit
//
//  Created by Frain on 2020/6/8.
//

import Foundation

final class WrapperCoordinatorContext<SourceBase, Other>: ListCoordinatorContext<SourceBase>
where SourceBase: DataSource, SourceBase.SourceBase == SourceBase, Other: DataSource {
    var coordinator: WrapperCoordinator<SourceBase, Other>
    
    lazy var extraSelectorWithSubContext = configSelectedSet()
    var wrapped: ListCoordinatorContext<Other.SourceBase>? { coordinator.wrapped?.context }
    
    override var extraSelectors: Set<Selector> { extraSelectorWithSubContext }
    
    init(_ coordinator: WrapperCoordinator<SourceBase, Other>) {
        self.coordinator = coordinator
        super.init(coordinator)
    }
    
    func configSelectedSet() -> Set<Selector> {
        var selectors = listDelegate.extraSelectors
        wrapped.map {
            $0.listDelegate.functions.keys.forEach { selectors.insert($0) }
            selectors.formUnion($0.extraSelectors)
        }
        return selectors
    }
    
    override func reconfig() {
        extraSelectorWithSubContext = configSelectedSet()
        resetDelegates?()
    }
    
    override func cache<ItemCache>(for cached: inout Any?, at indexPath: IndexPath) -> ItemCache {
        guard listDelegate.getCache == nil, let wrapped = wrapped else {
            return super.cache(for: &cached, at: indexPath)
        }
        return wrapped.cache(for: &cached, at: indexPath)
    }
    
    // Selectors
    override func apply<Object: AnyObject, Target, Input, Output, Closure>(
        _ function: ListDelegate.Function<Object, Delegate, Target, Input, Output, Closure>,
        root: CoordinatorContext,
        object: Object,
        with input: Input
    ) -> Output? {
        let output = wrapped?.apply(function, root: root, object: object, with: input)
        if function.noOutput {
            return super.apply(function, root: root, object: object, with: input) ?? output
        } else {
            return output ?? super.apply(function, root: root, object: object, with: input)
        }
    }
    
    override func apply<Object: AnyObject, Target, Input, Output, Closure, Index: ListIndex>(
        _ function: ListDelegate.IndexFunction<Object, Delegate, Target, Input, Output, Closure, Index>,
        root: CoordinatorContext,
        object: Object,
        with input: Input,
        _ offset: Index
    ) -> Output? {
        let output = wrapped?.apply(function, root: root, object: object, with: input, offset)
        if function.noOutput {
            return super.apply(function, root: root, object: object, with: input, offset) ?? output
        } else {
            return output ?? super.apply(function, root: root, object: object, with: input, offset)
        }
    }
}
