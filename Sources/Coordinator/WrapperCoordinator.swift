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

    let toModel: (Other.Model) -> SourceBase.Model
    let toOther: (SourceBase.Source) -> Other?

    var rawOptions = ListOptions()
    var wrapped: Wrapped?

    override var sourceBaseType: Any.Type { Other.SourceBase.self }

    init(
        _ sourceBase: SourceBase,
        toModel: @escaping (Other.Model) -> SourceBase.Model,
        toOther: @escaping (SourceBase.Source) -> Other?
    ) {
        self.toModel = toModel
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
        context.contextAtIndex = { [weak self] (_, offset, listView) in
            self?.offsetAndRoot(offset: offset, list: listView) ?? []
        }
        return .init(value: other, context: context)
    }

    func update(from: Wrapped?, to: Wrapped?, way: ListUpdateWay<Model>?) -> Subupdate? {
        switch (from, to) {
        case (nil, nil):
            return nil
        case (nil, let to?):
            return to.coordinator.update(update: .insert)
        case (let from?, nil):
            return  from.coordinator.update(update: .remove)
        case (let from?, let to?):
            let updateWay =  way.map { ListUpdateWay($0, cast: toModel) }
            return to.coordinator.update(from: from.coordinator, updateWay: updateWay)
        }
    }

    override func numbersOfSections() -> Int {
        if sourceType == .models, wrapped == nil { return 1 }
        if sourceType == .sectionModels, wrapped?.coordinator.numbersOfModel(in: 0) == 0 {
            return options.removeEmptySection ? 0 : 1
        }
        return wrapped?.coordinator.numbersOfSections() ?? 0
    }

    override func numbersOfModel(in section: Int) -> Int {
        wrapped?.coordinator.numbersOfModel(in: section) ?? 0
    }

    override func model(at indexPath: IndexPath) -> Model {
        toModel(wrapped!.coordinator.model(at: indexPath))
    }

    override func cache<ModelCache>(
        for cached: inout Any?,
        at indexPath: IndexPath,
        in delegate: ListDelegate
    ) -> ModelCache {
        guard delegate.getCache == nil, let wrapped = wrapped else {
            return super.cache(for: &cached, at: indexPath, in: delegate)
        }
        return wrapped.coordinator.cache(for: &cached, at: indexPath, in: wrapped.context.listDelegate)
    }

    override func configSourceType() -> SourceType {
        if wrapped?.coordinator.sourceType == .models, isSectioned { return .sectionModels }
        return wrapped?.coordinator.sourceType ?? .models
    }

    // Selectors
    override func configExtraSelector(delegate: ListDelegate) -> Set<Selector>? {
        guard let wrapped = wrapped, delegate.extraSelectors.isEmpty else { return nil }
        let subdelegate = wrapped.context.listDelegate
        var selectors = wrapped.coordinator.configExtraSelector(delegate: subdelegate) ?? []
        subdelegate.functions.keys.forEach { selectors.insert($0) }
        return selectors
    }

    override func apply<V: AnyObject, Input, Output>(
        _ selector: Selector,
        for context: Context,
        root: CoordinatorContext,
        view: V,
        with input: Input
    ) -> Output? {
        guard context.extraSelectors.contains(selector) else {
            return super.apply(selector, for: context, root: root, view: view, with: input)
        }
        let output: Output? = wrapped.flatMap {
            $0.context.apply(selector, root: root, view: view, with: input)
        }
        if Output.self == Void.self {
            return super.apply(selector, for: context, root: root, view: view, with: input) ?? output
        } else {
            return output ?? super.apply(selector, for: context, root: root, view: view, with: input)
        }
    }

    override func apply<V: AnyObject, Input, Output, Index: ListIndex>(
        _ selector: Selector,
        for context: Context,
        root: CoordinatorContext,
        view: V,
        with input: Input,
        index: Index,
        _ offset: Index
    ) -> Output? {
        guard context.extraSelectors.contains(selector) else {
            return super.apply(selector, for: context, root: root, view: view, with: input, index: index, offset)
        }
        let output: Output? = wrapped.flatMap {
            $0.coordinator.apply(selector, for: $0.context, root: root, view: view, with: input, index: index, offset)
        }
        if Output.self == Void.self {
            return super.apply(selector, for: context, root: root, view: view, with: input, index: index, offset) ?? output
        } else {
            return output ?? super.apply(selector, for: context, root: root, view: view, with: input, index: index, offset)
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
        updateWay: ListUpdateWay<Model>?
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
                let way = ListUpdateWay(whole.way, cast: toModel)
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

extension WrapperCoordinator where SourceBase.Source == Other, SourceBase.Model == Other.Model {
    convenience init(wrapper sourceBase: SourceBase) {
        self.init(sourceBase, toModel: { $0 }, toOther: { $0 })
    }
}
