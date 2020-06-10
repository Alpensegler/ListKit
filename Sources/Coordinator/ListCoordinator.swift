//
//  ListCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/11/25.
//

enum SourceMultipleType {
    case single, multiple, sources, noneDiffable
}

struct WeakContext<SourceBase: DataSource> where SourceBase.SourceBase == SourceBase {
    weak var context: ListCoordinatorContext<SourceBase>?
    
    init(_ context: ListCoordinatorContext<SourceBase>) {
        self.context = context
    }
}

public class ListCoordinator<SourceBase: DataSource> where SourceBase.SourceBase == SourceBase {
    typealias Item = SourceBase.Item
    
    weak var storage: CoordinatorStorage<SourceBase>?
    var listContexts = [WeakContext<SourceBase>]()
    
    lazy var keepSection = options.contains(.init(rawValue: 1))
    lazy var preferSection = options.contains(.init(rawValue: 2))
    
    // Source Diffing
    var id: AnyHashable
    
    lazy var isSectioned = configureIsSectioned()
    var multiType: SourceMultipleType { .sources }
    var isEmpty: Bool { false }
    
    let update: ListUpdate<Item>
    let options: ListOptions<SourceBase>
    
    var selectorsHasSection: Bool {
        listContexts.contains { $0.context?.selectorSets.hasIndex == true }
    }
    
    var source: SourceBase.Source!
    
    init(
        source: SourceBase.Source!,
        update: ListUpdate<Item> = .init(),
        options: ListOptions<SourceBase> = .init(),
        id: AnyHashable = ObjectIdentifier(SourceBase.self)
    ) {
        self.id = id
        self.source = source
        self.update = update
        self.options = options
    }
    
    init(_ sourceBase: SourceBase, id: AnyHashable = ObjectIdentifier(SourceBase.self)) {
        self.id = id
        self.source = sourceBase.source
        self.update = sourceBase.listUpdate
        self.options = sourceBase.listOptions
    }
    
    func numbersOfSections() -> Int { fatalError() }
    func numbersOfItems(in section: Int) -> Int { fatalError() }
    
    func item(at section: Int, _ item: Int) -> Item { fatalError() }
    func itemRelatedCache(at section: Int, _ item: Int) -> ItemRelatedCache { fatalError() }
    
    func configureIsSectioned() -> Bool { fatalError() }
    
    // Setup
    func context(
        with setups: [(ListCoordinatorContext<SourceBase>) -> Void] = []
    ) -> ListCoordinatorContext<SourceBase> {
        let context = ListCoordinatorContext(self, setups: setups)
        listContexts.append(.init(context))
        return context
    }
    
    // Updates:
    func identifier(for sourceBase: SourceBase) -> AnyHashable {
        guard let identifier = options.differ?.identifier else {
            return HashCombiner(id, isSectioned, multiType)
        }
        return HashCombiner(id, isSectioned, multiType, identifier(sourceBase))
    }
    
    func equal(lhs: SourceBase, rhs: SourceBase) -> Bool {
        options.differ?.areEquivalent?(lhs, rhs) ?? true
    }
    
    func difference(
        from coordinator: ListCoordinator<SourceBase>,
        differ: Differ<Item>?
    ) -> CoordinatorDifference {
        fatalError("should be implemented by subclass")
    }

    func difference(
        to source: SourceBase.Source,
        differ: Differ<Item>
    ) -> CoordinatorDifference {
        fatalError("should be implemented by subclass")
    }
    
    func updateTo(_ source: SourceBase.Source) {
        self.source = source
    }
    
    func startUpdate() {
        
    }
    
    func endUpdate(animated: Bool = true, completion: ((ListView, Bool) -> Void)? = nil) {
        
    }
    
    func performReload(
        to sourceBase: SourceBase.Source,
        _ animated: Bool,
        _ completion: ((ListView, Bool) -> Void)?,
        _ updateData: ((SourceBase.Source) -> Void)?
    ) {
        updateTo(sourceBase)
        updateData?(sourceBase)
//        for (sectionOffset, itemOffset, listView, context) in contexts {
//            if context != nil {
//                
//            } else {
//                listView.reloadSynchronously(animated: animated)
//                completion?(listView, true)
//            }
//        }
    }
    
    func perform(
        diff differ: Differ<Item>,
        to source: SourceBase.Source,
        _ animated: Bool,
        _ completion: ((ListView, Bool) -> Void)?,
        _ updateData: ((SourceBase.Source) -> Void)?
    ) {
//        let contexts = self.contexts
//        if contexts.isEmpty { return }
//        let change = updateData.map { update in { update(self.source) } }
//        let difference = self.difference(to: source, differ: differ)
//        guard difference.updates != nil else {
//            contexts.forEach { completion?($0.2, true) }
//            return
//        }
//        for (sectionOffset, itemOffset, listView, context) in contexts {
//            let updates = difference.generateListUpdates(itemSources: context?.itemSources)
//            listView.perform(
//                updates: updates,
//                sectionOffset: sectionOffset,
//                itemOffset: itemOffset,
//                animated: animated,
//                change: change,
//                completion: completion
//            )
//        }
    }
    
    func perform(
        _ update: ListUpdate<Item>,
        to source: SourceBase.Source,
        _ animated: Bool,
        _ completion: ((ListView, Bool) -> Void)?,
        _ updateData: ((SourceBase.Source) -> Void)?
    ) {
        Log.log("update from \(self.source!)")
        Log.log("update to   \(source)")
        switch update.way {
        case .diff(let diff):
            perform(diff: diff, to: source, animated, completion, updateData)
        case .reload:
            performReload(to: source, animated, completion, updateData)
        }
    }
    
    func removeCurrent(animated: Bool, completion: ((ListView, Bool) -> Void)?) {
        
    }
}
