//
//  WrapperCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

import Foundation

final class WrapperCoordinator<SourceBase: DataSource, Other>: ListCoordinator<SourceBase>
where SourceBase.SourceBase == SourceBase, Other: DataSource {
    let wrapped: Other
    let wrappedCoodinator: ListCoordinator<Other.SourceBase>
    let itemTransform: (Other.Item) -> SourceBase.Item
    
    override var multiType: SourceMultipleType { wrappedCoodinator.multiType }
    override var isEmpty: Bool { wrappedCoodinator.isEmpty }
    
    init(
        _ sourceBase: SourceBase,
        wrapped: Other,
        itemTransform: @escaping (Other.Item) -> SourceBase.Item
    ) {
        self.wrapped = wrapped
        self.wrappedCoodinator = wrapped.listCoordinator
        self.itemTransform = itemTransform
        let id = HashCombiner(ObjectIdentifier(SourceBase.self), wrappedCoodinator.id)
        super.init(sourceBase, id: id)
    }
    
    override func item(at section: Int, _ item: Int) -> Item {
        itemTransform(wrappedCoodinator.item(at: section, item))
    }
    
    override func itemRelatedCache(at section: Int, _ item: Int) -> ItemRelatedCache {
        wrappedCoodinator.itemRelatedCache(at: section, item)
    }
    
    override func numbersOfSections() -> Int {
        wrappedCoodinator.numbersOfSections()
    }
    
    override func numbersOfItems(in section: Int) -> Int {
        wrappedCoodinator.numbersOfItems(in: section)
    }
    
    override func configureIsSectioned() -> Bool {
        wrappedCoodinator.isSectioned || selectorsHasSection ? true : wrappedCoodinator.isSectioned
    }
    
    // Setup
    override func context(
        with setups: [(ListCoordinatorContext<SourceBase>) -> Void] = []
    ) -> ListCoordinatorContext<SourceBase> {
        let context = WrapperCoordinatorContext<SourceBase, Other>(
            wrappedCoodinator.context(with: wrapped.listContextSetups),
            self,
            setups: setups
        )
        listContexts.append(.init(context))
        return context
    }
    
    // Diffs:
}

extension WrapperCoordinator where SourceBase.Source == Other, SourceBase.Item == Other.Item {
    convenience init(wrapper sourceBase: SourceBase) {
        self.init(sourceBase, wrapped: sourceBase.source) { $0 }
    }
}
