//
//  AdapterCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

final class AdapterCoordinator<SourceBase: DataSource>: ItemTypedWrapperCoordinator<SourceBase>
where SourceBase.SourceBase == SourceBase {
    var storedSource: SourceBase
    lazy var coordinator = storedSource.listCoordinator
    override var source: SourceBase.Source { coordinator.source }
    override var wrappedCoodinator: BaseCoordinator { coordinator }
    override var wrappedItemTypedCoodinator: ItemTypedCoorinator<Item> { coordinator }
    
    override var selfType: ObjectIdentifier {
        get { wrappedCoodinator.selfType }
        set { wrappedCoodinator.selfType = newValue }
    }
    
    override var stagingDelegatesSetups: [(ListDelegates<SourceBase>) -> Void] {
        get { coordinator.stagingDelegatesSetups }
        set { coordinator.stagingDelegatesSetups = newValue }
    }
    
    override var delegatesStorage: [ObjectIdentifier: ListDelegates<SourceBase>]  {
        get { coordinator.delegatesStorage }
        set { coordinator.delegatesStorage = newValue }
    }
    
    override init(sourceBase: SourceBase) {
        storedSource = sourceBase
        
        super.init(sourceBase: sourceBase)
    }
    
    override func setup(
        listView: SetuptableListView,
        objectIdentifier: ObjectIdentifier,
        sectionOffset: Int = 0,
        itemOffset: Int = 0,
        isRoot: Bool = false
    ) -> Delegates {
        wrappedCoodinator.setup(
            listView: listView,
            objectIdentifier: objectIdentifier,
            sectionOffset: sectionOffset,
            itemOffset: itemOffset,
            isRoot: isRoot
        )
    }
}
