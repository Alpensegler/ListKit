//
//  ListCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/11/25.
//

public class ListCoordinator<SourceBase: DataSource>: ItemTypedCoorinator<SourceBase.Item> {
    typealias Item = SourceBase.Item
    
    var nestedAdapterUpdate = [AnyHashable: (SourceBase) -> Void]()
    var nestedAdapterItemUpdate = [AnyHashable: (Item) -> Void]()
    var stagingDelegatesSetups = [(ListDelegates<SourceBase>) -> Void]()
    var delegatesStorage = [ObjectIdentifier: ListDelegates<SourceBase>]()
    var source: SourceBase.Source { fatalError() }
    var didSetup = false
    
    func setup(with delegates: Delegates) { }
    
    override var anySource: Any { source }
    
    override init() {
        super.init()
    }
    
    init(sourceBase: SourceBase) {
        super.init()
        
        selfType = ObjectIdentifier(SourceBase.self)
        itemType = ObjectIdentifier(SourceBase.Item.self)
    }
    
    func update(
        to sourceBase: SourceBase,
        from coordinator: ListCoordinator<SourceBase>,
        completion: @escaping () -> Void
    ) {
        nestedAdapterUpdate = coordinator.nestedAdapterUpdate
        nestedAdapterUpdate.values.forEach { $0(sourceBase) }
        fatalError()
    }
    
    @discardableResult
    override func setup(
        listView: SetuptableListView,
        objectIdentifier: ObjectIdentifier,
        sectionOffset: Int = 0,
        itemOffset: Int = 0,
        isRoot: Bool = false
    ) -> Delegates {
        let delegates = delegatesStorage[objectIdentifier] ?? {
            let context = ListDelegates(coordinator: self, listView: listView)
            delegatesStorage[objectIdentifier] = context
            stagingDelegatesSetups.forEach { $0(context) }
            if !didSetup {
                setup(with: context)
                didSetup = true
            }
            return context
        }()
        delegates.sectionOffset = sectionOffset
        delegates.itemOffset = itemOffset
        delegates.setup(isRoot: isRoot, listView: listView)
        return delegates
    }
}
