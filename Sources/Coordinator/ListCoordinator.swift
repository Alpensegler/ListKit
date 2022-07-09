//
//  ListCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/11/25.
//

import Foundation

public class ListCoordinator<SourceBase: DataSource> where SourceBase.SourceBase == SourceBase {
    typealias Item = SourceBase.Item
    typealias Indices = ContiguousArray<(index: Int, isFake: Bool)>
    typealias Context = ListCoordinatorContext<SourceBase>

    struct WeakContext {
        weak var context: ListCoordinatorContext<SourceBase>?
    }

    let update: ListUpdate<SourceBase>.Whole
    let differ: ListDiffer<SourceBase>
    var options: ListOptions
    var source: SourceBase.Source!

    weak var storage: CoordinatorStorage<SourceBase>?
    weak var currentCoordinatorUpdate: ListCoordinatorUpdate<SourceBase>?
    var listContexts = [WeakContext]()

    lazy var sourceType = configSourceType()

    var sourceBaseType: Any.Type { SourceBase.self }
    var isSectioned: Bool {
        options.preferSection || listContexts.contains {
            $0.context?.listDelegate.hasSectionIndex == true
        }
    }

    init(
        source: SourceBase.Source!,
        update: ListUpdate<SourceBase>.Whole,
        differ: ListDiffer<SourceBase> = .none,
        options: ListOptions = .none
    ) {
        self.update = update
        self.differ = differ
        self.options = options
        self.source = source
    }

    init(_ sourceBase: SourceBase) {
        self.differ = sourceBase.listDiffer
        self.update = sourceBase.listUpdate
        self.options = sourceBase.listOptions
        self.source = sourceBase.source
    }

    func numbersOfSections() -> Int { notImplemented() }
    func numbersOfItems(in section: Int) -> Int { notImplemented() }

    func item(at indexPath: IndexPath) -> Item { notImplemented() }

    func cache<ItemCache>(
        for cached: inout Any?,
        at indexPath: IndexPath,
        in delegate: ListDelegate
    ) -> ItemCache {
        guard let getCache = delegate.getCache as? (Item) -> ItemCache else {
            fatalError("\(SourceBase.self) no cache with \(ItemCache.self)")
        }
        let cache = getCache(item(at: indexPath))
        cached = cache
        return cache
    }

    func configSourceType() -> SourceType { notImplemented() }

    // Selectors:
    func configExtraSelector(delegate: ListDelegate) -> Set<Selector>? { nil }

    @discardableResult
    func apply<Object: AnyObject, Target, Input, Output, Closure>(
        _ function: ListDelegate.Function<Object, Delegate, Target, Input, Output, Closure>,
        for context: Context,
        root: CoordinatorContext,
        object: Object,
        with input: Input
    ) -> Output? {
        guard let rawClosure = context.listDelegate.functions[function.selector],
              let closure = rawClosure as? (Object, Context, CoordinatorContext, Input) -> Output
        else { return nil }
        return closure(object, context, root, input)
    }

    // swiftlint:disable function_parameter_count
    @discardableResult
    func apply<Object: AnyObject, Target, Input, Output, Closure, Index: ListIndex>(
        _ function: ListDelegate.IndexFunction<Object, Delegate, Target, Input, Output, Closure, Index>,
        for context: Context,
        root: CoordinatorContext,
        object: Object,
        with input: Input,
        _ offset: Index
    ) -> Output? {
        guard let rawClosure = context.listDelegate.functions[function.selector],
              let closure = rawClosure as? (Object, Context, CoordinatorContext, Input, Index, Index) -> Output
        else { return nil }
        return closure(object, context, root, input, function.indexForInput(input), offset)
    }
    // swiftlint:enable function_parameter_count

    // Updates:
    func identifier(for sourceBase: SourceBase) -> [AnyHashable] {
        let id = ObjectIdentifier(sourceBaseType)
        guard let identifier = differ.identifier else { return [id, sourceType] }
        return [id, sourceType, identifier(sourceBase)]
    }

    func equal(lhs: SourceBase, rhs: SourceBase) -> Bool {
        differ.areEquivalent?(lhs, rhs) ?? true
    }

    func update(
        update: ListUpdate<SourceBase>,
        options: ListOptions? = nil
    ) -> ListCoordinatorUpdate<SourceBase> {
        notImplemented()
    }

    func update(
        from coordinator: ListCoordinator<SourceBase>,
        updateWay: ListUpdateWay<Item>?
    ) -> ListCoordinatorUpdate<SourceBase> {
        notImplemented()
    }
}

extension ListCoordinator {
    func contextAndUpdates(update: CoordinatorUpdate) -> [(CoordinatorContext, CoordinatorUpdate)]? {
        var results: [(CoordinatorContext, CoordinatorUpdate)]?
        for context in listContexts {
            guard let context = context.context else { continue }
            if context.listView != nil {
                results = results.map { $0 + [(context, update)] } ?? [(context, update)]
            } else if let parentUpdate = context.update?(context.index, update) {
                results = results.map { $0 + parentUpdate } ?? parentUpdate
            }
        }
        return results
    }

    func offsetAndRoot(offset: IndexPath, list: ListView) -> [(IndexPath, CoordinatorContext)] {
        var results = [(IndexPath, CoordinatorContext)]()
        for context in self.listContexts {
            guard let context = context.context else { continue }
            if context.listView === list {
                results.append((offset, context))
            }

            results += context.contextAtIndex?(context.index, offset, list) ?? []
        }
        return results
    }

    func resetDelegates() {
        listContexts.forEach { $0.context?.reconfig() }
    }
}
