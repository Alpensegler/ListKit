//
//  SourceDelegates.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

class SourceDelegates<SourceBase: DataSource>: WrapperDelegates<SourceBase> {
    let otherDelegate: Delegates
    override var others: SelectorSets { otherDelegate.selectorSets }
    
    init(
        coordinator: ListCoordinator<SourceBase>,
        other: Delegates,
        listView: SetuptableListView
    ) {
        self.otherDelegate = other
        super.init(coordinator: coordinator, listView: listView)
    }
    
    override func subdelegates<Object: AnyObject, Input, Output>(
        for delegate: Delegate<Object, Input, Output>,
        object: Object,
        with input: Input
    ) -> Delegates? {
        others.contains(delegate.selector) ? nil : otherDelegate
    }
}
