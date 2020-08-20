//
//  WrapperCoordinatorContext.swift
//  ListKit
//
//  Created by Frain on 2020/6/8.
//

class WrapperCoordinatorContext<SourceBase, Other>: ListCoordinatorContext<SourceBase>
where SourceBase: DataSource, SourceBase.SourceBase == SourceBase, Other: DataSource {
    lazy var finalSelectorSets = configSelectedSet()
    var wrapped: ListCoordinatorContext<Other.SourceBase>? {
        didSet { reconfig() }
    }
    
    override var index: Int {
        didSet { wrapped?.index = index }
    }
    
    override var update: ((Int, CoordinatorUpdate, Bool) -> [(CoordinatorContext, CoordinatorUpdate)])? {
        didSet { wrapped?.update = update }
    }
    
    override var listViewGetter: (() -> ListView?)? {
        didSet { wrapped?.listViewGetter = listViewGetter }
    }
    
    override var selectorSets: SelectorSets { finalSelectorSets }
    
    init(
        _ wrapped: ListCoordinatorContext<Other.SourceBase>?,
        _ coordinator: ListCoordinator<SourceBase>,
        setups: [(ListCoordinatorContext<SourceBase>) -> Void]
    ) {
        self.wrapped = wrapped
        super.init(coordinator, setups: setups)
    }
    
    func configSelectedSet() -> SelectorSets {
        wrapped.map { SelectorSets(merging: selfSelectorSets, $0.selectorSets) } ?? selfSelectorSets
    }
    
    func subcontext<Object: AnyObject, Input, Output, Index>(
        for delegate: Delegate<Object, Input, Output, Index>,
        object: Object,
        with input: Input
    ) -> CoordinatorContext? {
        wrapped?.selectorSets.contains(delegate.selector) == true ? wrapped : nil
    }
    
    override func reconfig() {
        wrapped.map { ($0.index, $0.update) = (index, update) }
        finalSelectorSets = configSelectedSet()
        resetDelegates?()
        wrapped?.update = update
        wrapped?.index = index
        wrapped?.listViewGetter = listViewGetter
    }
    
    override func apply<Object: AnyObject, Input, Output, Index>(
        _ keyPath: KeyPath<CoordinatorContext, Delegate<Object, Input, Output, Index>>,
        root: CoordinatorContext,
        object: Object,
        with input: Input,
        _ sectionOffset: Int,
        _ itemOffset: Int
    ) -> Output? {
        let delegate = self[keyPath: keyPath]
        let context = subcontext(for: delegate, object: object, with: input)
        return context?.apply(keyPath, root: root, object: object, with: input, sectionOffset, itemOffset)
            ?? super.apply(keyPath, root: root, object: object, with: input, sectionOffset, itemOffset)
    }
    
    override func apply<Object: AnyObject, Input, Index>(
        _ keyPath: KeyPath<CoordinatorContext, Delegate<Object, Input, Void, Index>>,
        root: CoordinatorContext,
        object: Object,
        with input: Input,
        _ sectionOffset: Int,
        _ itemOffset: Int
    ) {
        let delegate = self[keyPath: keyPath]
        let context = subcontext(for: delegate, object: object, with: input)
        context?.apply(keyPath, root: root, object: object, with: input, sectionOffset, itemOffset)
        super.apply(keyPath, root: root, object: object, with: input, sectionOffset, itemOffset)
    }
}
