//
//  ListCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/11/25.
//

final class ListContext {
    weak var listView: ListView?
    var sectionOffset: Int
    var itemOffset: Int
    var supercoordinator: BaseCoordinator?
    
    init(listView: ListView?, sectionOffset: Int, itemOffset: Int, supercoordinator: BaseCoordinator?) {
        self.listView = listView
        self.sectionOffset = sectionOffset
        self.itemOffset = itemOffset
        self.supercoordinator = supercoordinator
    }
}

public class ListCoordinator<SourceBase: DataSource>: BaseCoordinator
where SourceBase.SourceBase == SourceBase {
    typealias Item = SourceBase.Item
    
    weak var storage: CoordinatorStorage<SourceBase>?
    
    var cacheFromItem: ((Item) -> Any)?
    var listContexts = [ObjectIdentifier: ListContext]()
    var didSetup = false
    
    var _id: AnyHashable
    var defaultUpdate = Update<Item>()
    var differ = Differ<SourceBase>()
    
    var source: SourceBase.Source { fatalError() }
    
    override var id: AnyHashable { _id }
    
    func item(at path: PathConvertible) -> Item { fatalError() }
    
    func configNestedIfNeeded() {
//        guard needUpdateCaches else { return }
//        itemCaches.enumerated().forEach { (arg) in
//            let section = arg.offset
//            arg.element.enumerated().forEach { (arg) in
//                let item = arg.offset
//                arg.element.nestedAdapterItemUpdate.values.forEach {
//                    if $0.0 { return }
//                    $0.1(self.item(at: Path(section: section, item: item)))
//                }
//            }
//        }
    }
    
    func configNestedNotNewIfNeeded() {
//        guard needUpdateCaches else { return }
//        for cache in itemCaches.lazy.flatMap({ $0 }) {
//            cache.nestedAdapterItemUpdate.keys.forEach {
//                cache.nestedAdapterItemUpdate[$0]?.0 = false
//            }
//        }
    }
    
    func offset(for object: AnyObject) -> (Int, Int) {
        guard let context = listContexts[ObjectIdentifier(object)] else { return (0, 0) }
        return (context.sectionOffset, context.itemOffset)
    }
    
    func setup() {
        didSetup = true
    }
    
    //Diffs:
    func itemDifference(
        from coordinator: BaseCoordinator,
        differ: Differ<Item>
    ) -> [Difference<ItemRelatedCache>] {
        fatalError()
    }
    
    func itemsDifference(
        from coordinator: BaseCoordinator,
        differ: Differ<Item>
    ) -> Difference<Void> {
        fatalError()
    }
    
    func sourcesDifference(
        from coordinator: BaseCoordinator,
        differ: Differ<Item>
    ) -> Difference<BaseCoordinator> {
        fatalError()
    }
    
    func performReload(
        to sourceBase: SourceBase,
        _ animated: Bool,
        _ completion: ((ListView, Bool) -> Void)?,
        _ updateData: ((SourceBase.Source) -> Void)?
    ) {
        for context in listContexts.values {
            guard let listView = context.listView else { continue }
            if let coordinator = context.supercoordinator {
                _ = coordinator
            } else {
                updateTo(sourceBase, with: updateData)
                context.listView?.reloadSynchronously(animated: animated)
                completion?(listView, true)
            }
        }
    }
    
    func perform(
        diff: Differ<Item>,
        to sourceBase: SourceBase,
        _ animated: Bool,
        _ completion: ((ListView, Bool) -> Void)?,
        _ updateData: ((SourceBase.Source) -> Void)?
    ) {
        fatalError()
    }
    
    func perform(
        _ update: Update<Item>,
        to sourceBase: SourceBase,
        _ animated: Bool,
        _ completion: ((ListView, Bool) -> Void)?,
        _ updateData: ((SourceBase.Source) -> Void)?
    ) {
        switch update.way {
        case .diff(let diff):
            perform(diff: diff, to: sourceBase, animated, completion, updateData)
        case .reload:
            performReload(to: sourceBase, animated, completion, updateData)
        }
    }
    
    func updateTo(_ sourceBase: SourceBase, with updateData: ((SourceBase.Source) -> Void)?) {
        
    }
    
    func removeCurrent(animated: Bool, completion: ((ListView, Bool) -> Void)?) {
        
    }
    
    //Selectors
    func set<Object: AnyObject, Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<BaseCoordinator, Delegate<Object, Input, Output>>,
        _ closure: @escaping (ListCoordinator<SourceBase>, Object, Input) -> Output
    ) {
        self[keyPath: keyPath].closure = { [unowned self] in closure(self, $0, $1) }
        let delegate = self[keyPath: keyPath]
        switch delegate.index {
        case .none: selectorSets { $0.value.remove(delegate.selector) }
        case .index: selectorSets { $0.withIndex.remove(delegate.selector) }
        case .indexPath: selectorSets { $0.withIndexPath.remove(delegate.selector) }
        }
    }

    func set<Object: AnyObject, Input>(
        _ keyPath: ReferenceWritableKeyPath<BaseCoordinator, Delegate<Object, Input, Void>>,
        _ closure: @escaping (ListCoordinator<SourceBase>, Object, Input) -> Void
    ) {
        self[keyPath: keyPath].closure = { [unowned self] in closure(self, $0, $1) }
        let delegate = self[keyPath: keyPath]
        selectorSets { $0.void.remove(delegate.selector) }
    }
    
    func selectorSets(applying: (inout SelectorSets) -> Void) {
        applying(&selectorSets)
    }
    
    override func anyItem(at path: PathConvertible) -> Any { item(at: path) }
    
    override func setup(
        listView: ListView,
        key: ObjectIdentifier,
        sectionOffset: Int = 0,
        itemOffset: Int = 0,
        supercoordinator: BaseCoordinator? = nil
    ) {
        if let context = listContexts[key] {
            context.sectionOffset = sectionOffset
            context.itemOffset = itemOffset
            return
        }
        
        let context = ListContext(
            listView: listView,
            sectionOffset: sectionOffset,
            itemOffset: itemOffset,
            supercoordinator: supercoordinator
        )
        listContexts[key] = context
        if !didSetup { setup() }
    }
    
    init(update: Update<Item> = .init(), storage: CoordinatorStorage<SourceBase>? = nil) {
        _id = ObjectIdentifier(SourceBase.self)
        super.init()
        
        self.storage = storage
        self.defaultUpdate = update
    }
    
    init(_ sourceBase: SourceBase, storage: CoordinatorStorage<SourceBase>?) {
        _id = ObjectIdentifier(SourceBase.self)
        
        super.init()
        
        self.storage = storage
        self.defaultUpdate = sourceBase.listUpdate
    }
}
