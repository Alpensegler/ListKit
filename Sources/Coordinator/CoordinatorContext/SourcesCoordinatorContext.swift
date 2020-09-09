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
    lazy var finalSelectorSets = configSelectedSet()
    let coordinator: SourcesCoordinator<SourceBase, Source>
    
    override var selectorSets: SelectorSets { finalSelectorSets }
    
    init(
        _ coordinator: SourcesCoordinator<SourceBase, Source>,
        setups: [(ListCoordinatorContext<SourceBase>) -> Void]
    ) {
        self.coordinator = coordinator
        super.init(coordinator, setups: setups)
    }
    
    func configSelectedSet() -> SelectorSets {
        var selectors = selfSelectorSets
        for subsource in coordinator.subsources {
            selectors.void.formUnion(subsource.context.selectorSets.void)
            selectors.withIndex.formUnion(subsource.context.selectorSets.withIndex)
            selectors.withIndexPath.formUnion(subsource.context.selectorSets.withIndexPath)
        }
        return selectors
    }
    
    func subcoordinatorApply<Object: AnyObject, Input, Output, Index>(
        _ keyPath: KeyPath<CoordinatorContext, IndexDelegate<Object, Input, Output, Index>>,
        root: CoordinatorContext,
        object: Object,
        with input: Input,
        _ offset: Index
    ) -> Output? {
        let delegate = self[keyPath: keyPath], path = input[keyPath: delegate.index]
        let index = coordinator.sourceIndex(for: path.offseted(offset, plus: false))
        let context = coordinator.subsources[index]
        let offset = offset.offseted(context.offset, isSection: listCoordinator.sectioned)
        guard context.context.selectorSets.contains(delegate.selector) else { return nil }
        return context.context.apply(keyPath, root: root, object: object, with: input, offset)
    }
    
    override func reconfig() {
        finalSelectorSets = configSelectedSet()
        resetDelegates?()
    }
    
    override func apply<Object: AnyObject, Input>(
        _ keyPath: KeyPath<CoordinatorContext, Delegate<Object, Input, Void>>,
        root: CoordinatorContext,
        object: Object,
        with input: Input
    ) {
        let delegate = self[keyPath: keyPath]
        coordinator.subsources.forEach { (element) in
            guard element.context.selectorSets.contains(delegate.selector) else { return }
            element.context.apply(keyPath, root: root, object: object, with: input)
        }
        super.apply(keyPath, root: root, object: object, with: input)
    }
    
    override func apply<Object: AnyObject, Input, Output, Index>(
        _ keyPath: KeyPath<CoordinatorContext, IndexDelegate<Object, Input, Output, Index>>,
        root: CoordinatorContext,
        object: Object,
        with input: Input,
        _ offset: Index
    ) -> Output? {
        subcoordinatorApply(keyPath, root: root, object: object, with: input, offset)
            ?? super.apply(keyPath, root: root, object: object, with: input, offset)
    }
    
    override func apply<Object: AnyObject, Input, Index>(
        _ keyPath: KeyPath<CoordinatorContext, IndexDelegate<Object, Input, Void, Index>>,
        root: CoordinatorContext,
        object: Object,
        with input: Input,
        _ offset: Index
    ) {
        subcoordinatorApply(keyPath, root: root, object: object, with: input, offset)
        super.apply(keyPath, root: root, object: object, with: input, offset)
    }
}
