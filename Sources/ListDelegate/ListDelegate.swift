//
//  ListDelegate.swift
//  ListKit
//
//  Created by Frain on 2020/1/1.
//

import Foundation

final class ListDelegate: NSObject {
    unowned let listView: SetuptableListView
    private(set) var coordinator: Coordinator!
    
    init(_ listView: SetuptableListView) {
        self.listView = listView
    }
    
    func setCoordinator(
        coordinator: Coordinator,
        animated: Bool,
        completion: ((Bool) -> Void)?
    ) {
        let isDelegate = listView.isDelegate(self)
        let rawCoordinator = self.coordinator
        self.coordinator = coordinator
        coordinator.setup(listView: listView, key: ObjectIdentifier(listView))
        let updatable = isDelegate && rawCoordinator.map {
            coordinator.update(from: $0, animated: animated, completion: completion)
        } ?? false
        if updatable { return }
        if !isDelegate { listView.setup(with: self) }
        listView.reloadSynchronously(animated: animated)
        completion?(true)
    }
    
    func apply<Object: AnyObject, Input, Output>(
        _ keyPath: KeyPath<Coordinator, Delegate<Object, Input, Output>>,
        object: Object,
        with input: Input
    ) -> Output {
        coordinator.apply(keyPath, object: object, with: input)
    }
    
    func apply<Object: AnyObject, Input>(
        _ keyPath: KeyPath<Coordinator, Delegate<Object, Input, Void>>,
        object: Object,
        with input: Input
    ) {
        coordinator.apply(keyPath, object: object, with: input)
    }
    
    func apply<Object: AnyObject, Output>(
        _ keyPath: KeyPath<Coordinator, Delegate<Object, Void, Output>>,
        object: Object
    ) -> Output {
        apply(keyPath, object: object, with: ())
    }
    
    func apply<Object: AnyObject>(
        _ keyPath: KeyPath<Coordinator, Delegate<Object, Void, Void>>,
        object: Object
    ) {
        apply(keyPath, object: object, with: ())
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        if aSelector.map(coordinator.selectorSets.contains) == true { return false }
        return super.responds(to: aSelector)
    }

}
