//
//  WrapperCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

import Foundation

final class WrapperCoordinator<SourceBase: DataSource, Other>: ListCoordinator<SourceBase>
where SourceBase.SourceBase == SourceBase, Other: DataSource {
    typealias Subupdate = ListCoordinatorUpdate<Other.SourceBase>
    struct Wrapped {
        var value: Other
        var context: ListCoordinatorContext<Other.SourceBase>
        var coordinator: ListCoordinator<Other.SourceBase> { context.listCoordinator }
    }
    
    let toItem: (Other.Item) -> SourceBase.Item
    let toOther: (SourceBase.Source) -> Other?
    
    var rawOptions = ListOptions()
    var wrapped: Wrapped?
    
    override var sourceBaseType: Any.Type { Other.SourceBase.self }
    
    init(
        _ sourceBase: SourceBase,
        toItem: @escaping (Other.Item) -> SourceBase.Item,
        toOther: @escaping (SourceBase.Source) -> Other?
    ) {
        self.toItem = toItem
        self.toOther = toOther
        
        super.init(sourceBase)
        self.rawOptions = options
        self.wrapped = toOther(source).map(toWrapped)
        self.wrapped.map { options.formUnion($0.coordinator.options) }
    }
    
    func toWrapped(_ other: Other) -> Wrapped {
        let context = other.listCoordinatorContext
        context.update = { [weak self] (_, subupdate) in
            guard let self = self else { return nil }
            let subupdate = subupdate as! Subupdate
            let update = WrapperCoordinatorUpdate(
                coordinator: self,
                update: ListUpdate(subupdate.updateWay.other.map { .other($0) } ?? .subupdate),
                wrappeds: (self.wrapped, self.wrapped),
                sources: (self.source, self.source),
                subupdate: subupdate,
                options: (self.options, self.options)
            )
            return self.contextAndUpdates(update: update)
        }
        context.contextAtIndex = { [weak self] (index, offset, listView) in
            self?.offsetAndRoot(offset: offset, list: listView) ?? []
        }
        return .init(value: other, context: context)
    }
    
    func update(from: Wrapped?, to: Wrapped?, way: ListUpdateWay<Item>?) -> Subupdate? {
        switch (from, to) {
        case (nil, nil):
            return nil
        case (nil, let to?):
            return to.coordinator.update(update: .insert)
        case (let from?, nil):
            return  from.coordinator.update(update: .remove)
        case (let from?, let to?):
            let updateWay =  way.map { ListUpdateWay($0, cast: toItem) }
            return to.coordinator.update(from: from.coordinator, updateWay: updateWay)
        }
    }
    
    override func numbersOfSections() -> Int {
        if sourceType == .sectionItems, wrapped?.coordinator.numbersOfItems(in: 0) == 0 {
            return options.removeEmptySection ? 0 : 1
        }
        return wrapped?.coordinator.numbersOfSections() ?? 0
    }
    
    override func numbersOfItems(in section: Int) -> Int {
        wrapped?.coordinator.numbersOfItems(in: section) ?? 0
    }
    
    override func item(at indexPath: IndexPath) -> Item {
        toItem(wrapped!.coordinator.item(at: indexPath))
    }
    
    override func cache<ItemCache>(
        for cached: inout Any?,
        at indexPath: IndexPath,
        in delegate: ListDelegate
    ) -> ItemCache {
        guard delegate.getCache == nil, let wrapped = wrapped else {
            return super.cache(for: &cached, at: indexPath, in: delegate)
        }
        return wrapped.coordinator.cache(for: &cached, at: indexPath, in: wrapped.context.listDelegate)
    }
    
    override func configSourceType() -> SourceType {
        if wrapped?.coordinator.sourceType == .items, isSectioned { return .sectionItems }
        return wrapped?.coordinator.sourceType ?? .items
    }
    
    // Selectors
    override func configExtraSelector() -> Set<Selector>? {
        guard let wrapped = wrapped else { return nil }
        var selectors = wrapped.context.extraSelectors
        wrapped.context.listDelegate.functions.keys.forEach { selectors.insert($0) }
        return selectors
    }
    
    override func apply<Object: AnyObject, Target, Input, Output, Closure>(
        _ function: ListDelegate.Function<Object, Delegate, Target, Input, Output, Closure>,
        for context: Context,
        root: CoordinatorContext,
        object: Object,
        with input: Input
    ) -> Output? {
        guard context.extraSelectors.contains(function.selector) else {
            return super.apply(function, for: context, root: root, object: object, with: input)
        }
        let output = wrapped.flatMap {
            $0.context.apply(function, root: root, object: object, with: input)
        }
        if function.noOutput {
            return super.apply(function, for: context, root: root, object: object, with: input) ?? output
        } else {
            return output ?? super.apply(function, for: context, root: root, object: object, with: input)
        }
    }
    
    override func apply<Object: AnyObject, Target, Input, Output, Closure, Index: ListIndex>(
        _ function: ListDelegate.IndexFunction<Object, Delegate, Target, Input, Output, Closure, Index>,
        for context: Context,
        root: CoordinatorContext,
        object: Object,
        with input: Input,
        _ offset: Index
    ) -> Output? {
        guard context.extraSelectors.contains(function.selector) else {
            return super.apply(function, for: context, root: root, object: object, with: input, offset)
        }
        let output = wrapped.flatMap {
            $0.coordinator.apply(function, for: $0.context, root: root, object: object, with: input, offset)
        }
        if function.noOutput {
            return super.apply(function, for: context, root: root, object: object, with: input, offset) ?? output
        } else {
            return output ?? super.apply(function, for: context, root: root, object: object, with: input, offset)
        }
    }
    
    // Updates:
    override func identifier(for sourceBase: SourceBase) -> [AnyHashable] {
        let id = ObjectIdentifier(sourceBaseType)
        guard let identifier = differ.identifier else { return [id, sourceType] }
        return [id, sourceType, identifier(sourceBase)]
    }
    
    override func update(
        from coordinator: ListCoordinator<SourceBase>,
        updateWay: ListUpdateWay<Item>?
    ) -> ListCoordinatorUpdate<SourceBase> {
        let coordinator = coordinator as! WrapperCoordinator<SourceBase, Other>
        return WrapperCoordinatorUpdate(
            coordinator: self,
            update: ListUpdate(updateWay),
            wrappeds: (coordinator.wrapped, wrapped),
            sources: (coordinator.source, source),
            subupdate: update(from: coordinator.wrapped, to: wrapped, way: updateWay),
            options: (options, options)
        )
    }
    
    override func update(
        update: ListUpdate<SourceBase>,
        options: ListOptions? = nil
    ) -> ListCoordinatorUpdate<SourceBase> {
        let subupdate: Subupdate?, targetWrapped: Wrapped?, targetSource: SourceBase.Source!
        if case let .whole(whole) = update.updateType {
            if let source = update.source {
                targetSource = source
                targetWrapped = toOther(source).map(toWrapped)
                subupdate = self.update(from: wrapped, to: targetWrapped, way: whole.way)
            } else {
                let way = ListUpdateWay(whole.way, cast: toItem)
                targetSource = source
                targetWrapped = wrapped
                subupdate = wrapped?.coordinator.update(update: ListUpdate(way) ?? .reload)
            }
        } else {
            targetSource = source
            targetWrapped = wrapped
            subupdate = wrapped?.coordinator.update(update: .init(.init()))
        }
        
        return WrapperCoordinatorUpdate(
            coordinator: self,
            update: update,
            wrappeds: (wrapped, targetWrapped),
            sources: (source, targetSource),
            subupdate: subupdate,
            options: (self.options, options ?? self.options)
        )
    }
}

extension WrapperCoordinator where SourceBase.Source == Other, SourceBase.Item == Other.Item {
    convenience init(wrapper sourceBase: SourceBase) {
        self.init(sourceBase, toItem: { $0 }, toOther: { $0 })
    }
}
