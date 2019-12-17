//
//  WrapperDelegates.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

class WrapperDelegates<SourceBase: DataSource>: ListDelegates<SourceBase> {
    lazy var selfSelectorSets = initialSelectorSets()
    var others: SelectorSets { fatalError() }
    
    func setupSelectorSets() {
        selectorSets = SelectorSets(
            void: selfSelectorSets.void.intersection(others.void),
            value: selfSelectorSets.value.intersection(others.value),
            withIndex: selfSelectorSets.withIndex.intersection(others.withIndex),
            withIndexPath: selfSelectorSets.withIndexPath.intersection(others.withIndexPath),
            hasIndex: selfSelectorSets.hasIndex || others.hasIndex
        )
    }
    
    func subdelegates<Object: AnyObject, Input, Output>(
        for delegate: Delegate<Object, Input, Output>,
        object: Object,
        with input: Input
    ) -> Delegates? {
        fatalError()
    }
    
    override func selectorSets(applying: (inout SelectorSets) -> Void) {
        super.selectorSets(applying: applying)
        applying(&selfSelectorSets)
    }
    
    override func apply<Object: AnyObject, Input, Output>(
        _ keyPath: KeyPath<Delegates, Delegate<Object, Input, Output>>,
        object: Object,
        with input: Input
    ) -> Output {
        let closure = self[keyPath: keyPath]
        let delegates = subdelegates(for: closure, object: object, with: input)
        return delegates?.apply(keyPath, object: object, with: input)
            ?? super.apply(keyPath, object: object, with: input)
    }
    
    override func apply<Object: AnyObject, Input>(
        _ keyPath: KeyPath<Delegates, Delegate<Object, Input, Void>>,
        object: Object,
        with input: Input
    ) {
        let closure = self[keyPath: keyPath]
        let delegates = subdelegates(for: closure, object: object, with: input)
        delegates?.apply(keyPath, object: object, with: input)
        super.apply(keyPath, object: object, with: input)
    }
}
