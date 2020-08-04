//
//  WrapperCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

import Foundation

final class WrapperCoordinator<SourceBase: DataSource, Other>: ListCoordinator<SourceBase>
where SourceBase.SourceBase == SourceBase, Other: DataSource {
    typealias Wrapped = (value: Other, coordinator: ListCoordinator<Other.SourceBase>)
    
    var wrapped: Wrapped?
    let itemTransform: (Other.Item) -> SourceBase.Item
    
    override var isEmpty: Bool { wrapped?.coordinator.isEmpty != false }
    override var sourceBaseType: Any.Type { Other.SourceBase.self }
    
    init(
        _ sourceBase: SourceBase,
        wrapped: Other?,
        itemTransform: @escaping (Other.Item) -> SourceBase.Item
    ) {
        self.wrapped = wrapped.map { ($0, $0.listCoordinator) }
        self.itemTransform = itemTransform
        
        super.init(sourceBase)
    }
    
    func update(from: Wrapped?, to: Wrapped?, updateWay: ListUpdateWay<Item>?) -> CoordinatorUpdate {
        switch (from, to) {
        case (nil, nil):
            return .init()
        case (nil, let (_, to)?):
            return to.update(.insert)
        case (let (_, from)?, nil):
            return from.update(.remove)
        case (let (_, from)?, let (_, to)?):
            let updateWay = updateWay.map { ListUpdateWay($0, cast: itemTransform) }
            return to.update(from: from, updateWay: updateWay)
        }
    }
    
    override func item(at section: Int, _ item: Int) -> Item {
        itemTransform(wrapped!.coordinator.item(at: section, item))
    }
    
    override func numbersOfSections() -> Int {
        wrapped?.coordinator.numbersOfSections() ?? 0
    }
    
    override func numbersOfItems(in section: Int) -> Int {
        wrapped?.coordinator.numbersOfItems(in: section) ?? 0
    }
    
    override func isSectioned() -> Bool {
        if wrapped?.coordinator.sectioned == true || super.isSectioned() { return true }
        return wrapped?.coordinator.sectioned ?? super.isSectioned()
    }
    
    // Setup
    override func context(
        with setups: [(ListCoordinatorContext<SourceBase>) -> Void] = []
    ) -> ListCoordinatorContext<SourceBase> {
        let context = WrapperCoordinatorContext<SourceBase, Other>(
            wrapped.map { $0.coordinator.context(with: $0.value.listContextSetups) },
            self,
            setups: setups
        )
        listContexts.append(.init(context: context))
        return context
    }
    
    // Updates:
    override func identifier(for sourceBase: SourceBase) -> AnyHashable {
        let id = ObjectIdentifier(sourceBaseType)
        guard let identifier = options.differ?.identifier else {
            return HashCombiner(id, sectioned)
        }
        return HashCombiner(id, sectioned, identifier(sourceBase))
    }
    
    override func update(
        from coordinator: ListCoordinator<SourceBase>,
        updateWay: ListUpdateWay<Item>?
    ) -> CoordinatorUpdate {
        let coordinator = coordinator as! WrapperCoordinator<SourceBase, Other>
        return update(from: coordinator.wrapped, to: wrapped, updateWay: updateWay)
    }
    
    override func update(_ update: ListUpdate<SourceBase>) -> CoordinatorUpdate {
        guard case let .whole(whole, source as Other?) = update else { fatalError() }
        let wrapped: Wrapped? = source.map { ($0, $0.listCoordinator) }
        let context = wrapped.map { $0.coordinator.context(with: $0.value.listContextSetups) }
        listContexts.forEach {
            ($0.context as? WrapperCoordinatorContext<SourceBase, Other>)?.wrapped = context
        }
        defer { self.wrapped = wrapped }
        return self.update(from: self.wrapped, to: wrapped, updateWay: whole.way)
    }
}

extension WrapperCoordinator where SourceBase.Source == Other, SourceBase.Item == Other.Item {
    convenience init(wrapper sourceBase: SourceBase) {
        self.init(sourceBase, wrapped: sourceBase.source) { $0 }
    }
}
