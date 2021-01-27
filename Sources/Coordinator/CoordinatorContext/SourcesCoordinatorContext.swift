//
//  SourcesCoordinatorContext.swift
//  ListKit
//
//  Created by Frain on 2020/6/8.
//

import Foundation

final class SourcesCoordinatorContext<SourceBase, Source>: ListCoordinatorContext<SourceBase>
where
    SourceBase: DataSource,
    SourceBase.SourceBase == SourceBase,
    Source: RangeReplaceableCollection,
    Source.Element: DataSource,
    Source.Element.SourceBase.Item == SourceBase.Item
{
    lazy var extraSelectorWithSubContext = configSelectedSet()
    let coordinator: SourcesCoordinator<SourceBase, Source>
    
    override var extraSelectors: Set<Selector> { extraSelectorWithSubContext }
    
    init(_ coordinator: SourcesCoordinator<SourceBase, Source>) {
        self.coordinator = coordinator
        super.init(coordinator)
    }
    
    func configSelectedSet() -> Set<Selector> {
        var selectors = listDelegate.extraSelectors
        for subsource in coordinator.subsources {
            subsource.context.listDelegate.functions.keys.forEach { selectors.insert($0) }
            selectors.formUnion(subsource.context.extraSelectors)
        }
        return selectors
    }
    
    override func reconfig() {
        extraSelectorWithSubContext = configSelectedSet()
        resetDelegates?()
    }
    
    override func cache<ItemCache>(for cached: inout Any?, at indexPath: IndexPath) -> ItemCache {
        guard listDelegate.getCache == nil else { return super.cache(for: &cached, at: indexPath) }
        let (context, indexPath) = coordinator.subContextIndex(at: indexPath)
        return context.context.cache(for: &cached, at: indexPath)
    }
    
    override func apply<Object: AnyObject, Target, Input, Output, Closure>(
        _ function: ListDelegate.Function<Object, Delegate, Target, Input, Output, Closure>,
        root: CoordinatorContext,
        object: Object,
        with input: Input
    ) -> Output? {
        if function.noOutput {
            let output = coordinator.subsources.compactMap { (element) in
                element.context.apply(function, root: root, object: object, with: input)
            }.first
            return super.apply(function, root: root, object: object, with: input) ?? output
        } else {
            let output = coordinator.subsources.lazy.compactMap { (element) in
                element.context.apply(function, root: root, object: object, with: input)
            }.first
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
        let path = function.indexForInput(input)
        let index = coordinator.sourceIndex(for: path.offseted(offset, plus: false))
        let context = coordinator.subsources[index]
        let offset = offset.offseted(context.offset, isSection: listCoordinator.sourceType.isSection)
        let output = context.context.apply(function, root: root, object: object, with: input, offset)
        if function.noOutput {
            return super.apply(function, root: root, object: object, with: input, offset) ?? output
        } else {
            return output ?? super.apply(function, root: root, object: object, with: input, offset)
        }
    }
}
