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
        update: ListUpdate<SourceBase>.Whole?,
        animated: Bool,
        completion: ((Bool) -> Void)?
    ) {
        let isCoordinator = context?.isCoordinator(coordinator) ?? false
//        let rawcontext = context
        let context = coordinator.context(with: setups)
        context.listViewGetter = { [weak listView, weak context, weak self] in
            guard let self = self, let listView = listView else { return nil }
            return listView.isDelegate(self) && self.context === context ? listView : nil
        }
        context.resetDelegates = { [weak listView, weak self] in
            guard let listView = listView, let self = self else { return }
            listView.setup(with: self)
        }
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
        context.apply(keyPath, root: context, object: object, with: input)
    }
    
    func apply<Object: AnyObject, Input>(
        _ keyPath: KeyPath<CoordinatorContext, Delegate<Object, Input, Void>>,
        object: Object,
        with input: Input
    ) {
        context.apply(keyPath, root: context, object: object, with: input)
    }
    
    func apply<Object: AnyObject, Input, Output, Index: ListIndex>(
        _ keyPath: KeyPath<CoordinatorContext, IndexDelegate<Object, Input, Output, Index>>,
        object: Object,
        with input: Input
    ) -> Output {
        context.apply(keyPath, root: context, object: object, with: input, .zero) ??
            context[keyPath: keyPath].output(with: input, objct: object)
    }
    
    func apply<Object: AnyObject, Input, Index: ListIndex>(
        _ keyPath: KeyPath<CoordinatorContext, IndexDelegate<Object, Input, Void, Index>>,
        object: Object,
        with input: Input
    ) {
        context.apply(keyPath, root: context, object: object, with: input, .zero)
    }
    
    func apply<Object: AnyObject, Output>(
        _ keyPath: KeyPath<CoordinatorContext, Delegate<Object, Void, Output>>,
        object: Object
    ) -> Output {
        apply(keyPath, object: object, with: ())
    }
    
    func apply<Object: AnyObject, Output, Index: ListIndex>(
        _ keyPath: KeyPath<CoordinatorContext, IndexDelegate<Object, Void, Output, Index>>,
        object: Object
    ) -> Output {
        apply(keyPath, object: object, with: ())
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        guard allSelectors.contains(aSelector) else { return super.responds(to: aSelector) }
        return aSelector.map(context.selectorSets.contains) == true
    }
}

class ListDelegates<Object: AnyObject> {
    typealias Delegate<Input, Output> = ListKit.Delegate<Object, Input, Output>
    typealias SectionDelegate<Input, Output> = ListKit.IndexDelegate<Object, Input, Output, Int>
    typealias ItemDelegate<Input, Output> = ListKit.IndexDelegate<Object, Input, Output, IndexPath>
}

