//
//  ListCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/11/25.
//

public class ListCoordinator<SourceBase: DataSource>: ItemTypedCoorinator<SourceBase.Item> {
    typealias Item = SourceBase.Item
    
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
        if isRoot { listView.setup(with: delegates) }
        return delegates
    }
}
