//
//  ListDelegate.swift
//  ListKit
//
//  Created by Frain on 2020/1/1.
//

import Foundation

final class ListDelegate: NSObject {
    unowned let listView: SetuptableListView
    private(set) var context: CoordinatorContext!
    
    init(_ listView: SetuptableListView) {
        self.listView = listView
    }
    
    func setCoordinator<SourceBase: DataSource>(
        coordinator: ListCoordinator<SourceBase>,
        setups: [(ListCoordinatorContext<SourceBase>) -> Void],
        update: ListUpdate<SourceBase.Item>?,
        animated: Bool,
        completion: ((Bool) -> Void)?
    ) {
        let isCoordinator = context?.isCoordinator(coordinator) ?? false
//        let rawcontext = context
        let context = coordinator.context(with: setups)
        self.context = context
        if isCoordinator { return }
        if !listView.isDelegate(self) { listView.setup(with: self) }
//        let updatable = isDelegate && rawCoordinator.map {
//            coordinator.update(from: $0, animated: animated, completion: completion)
//        } ?? false
//        if updatable { return }
        listView.reloadSynchronously(animated: animated)
        completion?(true)
    }
    
    func apply<Object: AnyObject, Input, Output>(
        _ keyPath: KeyPath<CoordinatorContext, Delegate<Object, Input, Output>>,
        object: Object,
        with input: Input
    ) -> Output {
        context.apply(keyPath, object: object, with: input)
    }
    
    func apply<Object: AnyObject, Input>(
        _ keyPath: KeyPath<CoordinatorContext, Delegate<Object, Input, Void>>,
        object: Object,
        with input: Input
    ) {
        context.apply(keyPath, object: object, with: input)
    }
    
    func apply<Object: AnyObject, Output>(
        _ keyPath: KeyPath<CoordinatorContext, Delegate<Object, Void, Output>>,
        object: Object
    ) -> Output {
        apply(keyPath, object: object, with: ())
    }
    
    func apply<Object: AnyObject>(
        _ keyPath: KeyPath<CoordinatorContext, Delegate<Object, Void, Void>>,
        object: Object
    ) {
        apply(keyPath, object: object, with: ())
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        if aSelector.map(context.selectorSets.contains) == true { return false }
        return super.responds(to: aSelector)
    }
}
