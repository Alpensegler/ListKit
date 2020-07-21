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
    
    override var isEmpty: Bool { wrappedCoodinator.isEmpty }
    override var sourceBaseType: Any.Type { Other.SourceBase.self }
    
    init(
        _ sourceBase: SourceBase,
        wrapped: Other,
        itemTransform: @escaping (Other.Item) -> SourceBase.Item
    ) {
        self.wrapped = wrapped
        self.wrappedCoodinator = wrapped.listCoordinator
        self.itemTransform = itemTransform
        
        super.init(sourceBase)
    }
    
    override func item(at section: Int, _ item: Int) -> Item {
        itemTransform(wrappedCoodinator.item(at: section, item))
    }
    
    override func numbersOfSections() -> Int {
        wrappedCoodinator.numbersOfSections()
    }
    
    override func numbersOfItems(in section: Int) -> Int {
        wrappedCoodinator.numbersOfItems(in: section)
    }
    
    override func isSectioned() -> Bool {
        if wrappedCoodinator.sectioned || super.isSectioned() { return true }
        return wrappedCoodinator.sectioned
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
        listContexts.append(.init(context: context))
        return context
    }
    
    // Updates:
    override func identifier(for sourceBase: SourceBase) -> AnyHashable {
        let id = ObjectIdentifier(sourceBaseType)
        guard let identifier = options.differ?.identifier else {
            return HashCombiner(id, wrappedCoodinator.multiType, sectioned,  multiType)
        }
        let sourceBaseID = identifier(sourceBase)
        return HashCombiner(id, wrappedCoodinator.multiType, sectioned, multiType, sourceBaseID)
    }
}

extension WrapperCoordinator where SourceBase.Source == Other, SourceBase.Item == Other.Item {
    convenience init(wrapper sourceBase: SourceBase) {
        self.init(sourceBase, wrapped: sourceBase.source) { $0 }
    }
}
