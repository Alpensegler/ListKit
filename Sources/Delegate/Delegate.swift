//
//  ListDelegate.swift
//  ListKit
//
//  Created by Frain on 2020/1/1.
//

import Foundation

final class Delegate: NSObject {
    unowned let listView: SetuptableListView
    var context: CoordinatorContext!

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
        if update != nil { listView.reloadSynchronously(animated: animated) }
        completion?(true)
    }

    func apply<Input, Output>(
        _ selector: Selector,
        view: AnyObject,
        with input: Input,
        default: @autoclosure () -> Output
    ) -> Output {
        guard context.valid else { return `default`() }
        return context.apply(selector, root: context, view: view, with: input) ?? `default`()
    }

    func apply<Output>(
        _ selector: Selector,
        view: AnyObject,
        default: @autoclosure () -> Output
    ) -> Output {
        guard context.valid else { return `default`() }
        return context.apply(selector, root: context, view: view, with: ()) ?? `default`()
    }

    func apply<Input, Output, Index: ListIndex>(
        _ selector: Selector,
        view: AnyObject,
        with input: Input,
        index: Index,
        default: @autoclosure () -> Output
    ) -> Output {
        guard context.valid else { return `default`() }
        return context.apply(selector, root: context, view: view, with: input, index: index) ?? `default`()
    }

    override func responds(to aSelector: Selector!) -> Bool {
        guard allSelectors.contains(aSelector) else { return super.responds(to: aSelector) }
        return aSelector.map(context.contain(selector:)) == true
    }
}
