//
//  ListDelegate.swift
//  ListKit
//
//  Created by Frain on 2020/1/1.
//

import Foundation

final class Delegate: NSObject, DataSource {
    typealias Item = Never
    
    unowned let listView: SetuptableListView
    var context: CoordinatorContext!
    var source: Never { fatalError() }
    
    init(_ listView: SetuptableListView) {
        self.listView = listView
    }
    
    func setCoordinator<SourceBase: DataSource>(
        context: ListCoordinatorContext<SourceBase>,
        update: ListUpdate<SourceBase>.Whole?,
        animated: Bool,
        completion: ((Bool) -> Void)?
    ) {
        let isCoordinator = self.context?.isCoordinator(context.listCoordinator) ?? false
//        let rawcontext = context
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
    
    func apply<Object: AnyObject, Target, Input, Output, Closure>(
        _ function: ListDelegate.Function<Object, Delegate, Target, Input, Output, Closure>,
        object: Object,
        with input: Input
    ) -> Output? {
        context.apply(function, root: context, object: object, with: input)
    }
    
    func apply<Object: AnyObject, Target, Output, Closure>(
        _ function: ListDelegate.Function<Object, Delegate, Target, Void, Output, Closure>,
        object: Object
    ) -> Output? {
        context.apply(function, root: context, object: object, with: ())
    }
    
    func apply<Object: AnyObject, Target, Input, Output, Closure, Index: ListIndex>(
        _ function: ListDelegate.IndexFunction<Object, Delegate, Target, Input, Output, Closure, Index>,
        object: Object,
        with input: Input
    ) -> Output? {
        context.apply(function, root: context, object: object, with: input, .zero)
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        guard allSelectors.contains(aSelector) else { return super.responds(to: aSelector) }
        return aSelector.map(context.contain(selector:)) == true
    }
}

