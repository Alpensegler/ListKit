//
//  WrapperCoordinatorContext.swift
//  ListKit
//
//  Created by Frain on 2020/6/8.
//

class WrapperCoordinatorContext<SourceBase, Other>: ListCoordinatorContext<SourceBase>
where SourceBase: DataSource, SourceBase.SourceBase == SourceBase, Other: DataSource {
    let wrapped: ListCoordinatorContext<Other.SourceBase>
    
    func subcontext<Object: AnyObject, Input, Output>(
        for delegate: Delegate<Object, Input, Output>,
        object: Object,
        with input: Input
    ) -> CoordinatorContext? {
        wrapped.selectorSets.contains(delegate.selector) ? nil : wrapped
    }
    
    init(
        _ wrapped: ListCoordinatorContext<Other.SourceBase>,
        _ coordinator: ListCoordinator<SourceBase>,
        setups: [(ListCoordinatorContext<SourceBase>) -> Void]
    ) {
        self.wrapped = wrapped
        super.init(coordinator, setups: setups)
        selectorSets = SelectorSets(merging: selectorSets, wrapped.selectorSets)
    }
    
    override func apply<Object: AnyObject, Input, Output>(
        _ keyPath: KeyPath<CoordinatorContext, Delegate<Object, Input, Output>>,
        object: Object,
        with input: Input,
        _ sectionOffset: Int,
        _ itemOffset: Int
    ) -> Output {
        let delegate = self[keyPath: keyPath]
        let context = subcontext(for: delegate, object: object, with: input)
        return context?.apply(keyPath, object: object, with: input, sectionOffset, itemOffset)
            ?? super.apply(keyPath, object: object, with: input, sectionOffset, itemOffset)
    }
    
    override func apply<Object: AnyObject, Input>(
        _ keyPath: KeyPath<CoordinatorContext, Delegate<Object, Input, Void>>,
        object: Object,
        with input: Input,
        _ sectionOffset: Int,
        _ itemOffset: Int
    ) {
        let delegate = self[keyPath: keyPath]
        let context = subcontext(for: delegate, object: object, with: input)
        context?.apply(keyPath, object: object, with: input, sectionOffset, itemOffset)
        super.apply(keyPath, object: object, with: input, sectionOffset, itemOffset)
    }
}
