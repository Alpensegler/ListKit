//
//  BaseCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/10/12.
//

import ObjectiveC.runtime

public class BaseCoordinator: NSObject {
    enum SourceValue<OtherType, Coordinator, AssociatedValue, AssociatedDiffValue>
    where Coordinator: BaseCoordinator, OtherType: DiffEquatable {
        case single(DiffableSource<Coordinator, AssociatedValue, AssociatedDiffValue>)
        case multiple(DiffableSource<Coordinator, [AssociatedValue], AssociatedDiffValue>)
        case inSource(DiffableSource<Coordinator, [Self], AssociatedDiffValue>)
        case other(OtherType)
    }
    
    struct DiffableValue<Coordinator: BaseCoordinator> {
        let diffable: Diffable<Any>
        var coordinator: Coordinator
        var value: () -> Any
    }
    
    struct DiffableSource<Coordinator: BaseCoordinator, AssociatedValue, AssociatedDiffValue> {
        let diffableValue: DiffableValue<Coordinator>
        var associatedValue: () -> AssociatedValue = { fatalError() }
        var associatedDiffer: Differ<AssociatedDiffValue>?
        
        var associatedDiffEqual: (Self, Self) -> Bool = { _, _ in true }
        var associatedEqual: (Self, Self) -> Bool = { _, _ in true }
        var associatedHashInto: (Self, inout Hasher) -> Void = { _, _ in }
    }
    
    struct Other<Coordinator: BaseCoordinator, AssociatedValue, AssociatedDiffValue> {
        enum Cases {
            case cellContainer
            case noneDiffable
        }
        
        var type: Cases
        var diffable: () -> DiffableValue<Coordinator> = { fatalError() }
        var diffables: () -> [DiffableSource<Coordinator, AssociatedValue, AssociatedDiffValue>] = {
            fatalError()
        }
    }
    
    struct ListContext {
        let sectionOffset: Int
        let itemOffset: Int
        let listView: () -> ListView?
    }
    
    enum SourceType {
        case cell
        case section
    }
    
    enum SourceIndices: Equatable {
        case section(index: Int, count: Int)
        case cell(indices: [Int])
    }
    
    typealias SectionSourceValue<C: BaseCoordinator, A, D> = SourceValue<Other<C, A, D>, C, A, D>
    
    typealias AnyItemSources = SourceValue<Never, BaseCoordinator, Any, Any>
    typealias AnySectionSources = SectionSourceValue<BaseCoordinator, [Any], Any>
    typealias AnyDiffableSourceValue = DiffableValue<BaseCoordinator>
    
    //DelegatesValues
    
    lazy var selectorSets = initialSelectorSets()
    
    #if os(iOS) || os(tvOS)
    var scrollViewDelegates = UIScrollViewDelegates()
    
    var collectionViewDataSources = UICollectionViewDataSources()
    var collectionViewDelegates = UICollectionViewDelegates()
    var collectionViewDelegateFlowLayouts = UICollectionViewDelegateFlowLayouts()
    
    var tableViewDataSources = UITableViewDataSources()
    var tableViewDelegates = UITableViewDelegates()
    #endif
    
    var contexts = [ObjectIdentifier: ListContext]()
    
    //Updating
    var didUpdateToCoordinator = [(BaseCoordinator, BaseCoordinator) -> Void]()
    var didUpdateIndices = [() -> Void]()
    
    //Source Diffing
    var selfType = ObjectIdentifier(Any.self)
    var itemType = ObjectIdentifier(Any.self)
    
    var sourceType = SourceType.cell
    var sourceIndices = [SourceIndices]()
    var rangeReplacable = false
    var isEmpty: Bool { false }
    
    var anySource: Any { fatalError() }
    
    func anyItem<Path: PathConvertible>(at path: Path) -> Any { fatalError() }
    func numbersOfSections() -> Int { sourceIndices.count }
    func numbersOfItems(in section: Int) -> Int { sourceIndices[section].count }
    
    func anyItemSources<Source: DataSource>(source: Source) -> AnyItemSources { fatalError() }
    func anyItemApplyMultiItem(changes: ValueChanges<Any, Int>) { fatalError() }
    
    func anySectionSources<Source: DataSource>(source: Source) -> AnySectionSources { fatalError() }
    func anySectionApplyMultiSection(changes: ValueChanges<[Any], Int>) { fatalError() }
    func anySectionApplyItem(changes: [ValueChanges<Any, Int>]) { fatalError() }
    
    func anySourceUpdate(to sources: [AnyDiffableSourceValue]) { fatalError() }
    
    func addToSelectorSet(_ subselectorSets: inout SelectorSets, isAll: Bool = false) {
        guard !isAll else {
            subselectorSets = selectorSets
            return
        }
        if sourceType == .section {
            subselectorSets.withIndex.formUnion(selectorSets.withIndex)
        }
        subselectorSets.withIndexPath.formUnion(selectorSets.withIndexPath)
    }
    
    func applyBy(listView: ListView) {
        listView.setupWith(coordinator: self)
        applyBy(listView: listView, sectionOffset: 0, itemOffset: 0)
        listView.reloadSynchronously()
    }
    
    func applyBy(listView: ListView, sectionOffset: Int, itemOffset: Int) {
        contexts[ObjectIdentifier(listView)] = ListContext(
            sectionOffset: sectionOffset,
            itemOffset: itemOffset
        ) { [weak listView] in listView }
    }
    
    func update(
        from coordinator: BaseCoordinator,
        fromOffset: Path,
        toOffset: Path,
        isMove: Bool
    ) -> [(changes: ListChanges, update: () -> Void)] {
        fatalError()
    }
    
    //Responding
    func apply<Object: AnyObject, Input, Output>(
        _ keyPath: KeyPath<BaseCoordinator, Delegate<Object, Input, Output>>,
        object: Object,
        with input: Input
    ) -> Output {
        self[keyPath: keyPath].closure!(object, input)
    }
    
    func apply<Object: AnyObject, Input>(
        _ keyPath: KeyPath<BaseCoordinator, Delegate<Object, Input, Void>>,
        object: Object,
        with input: Input
    ) {
        self[keyPath: keyPath].closure?(object, input)
    }
    
    public override func responds(to aSelector: Selector!) -> Bool {
        if aSelector.map(selectorSets.contains) == true { return false }
        return superResponds(to: aSelector)
    }
    
    public func superResponds(to aSelector: Selector!) -> Bool {
        super.responds(to: aSelector)
    }
}

//Responding extension
extension BaseCoordinator {
    func offsets<Object: AnyObject>(for object: Object) -> (sectionOffset: Int, itemOffset: Int) {
        guard let context = contexts[ObjectIdentifier(object)] else { return (0, 0) }
        return (context.sectionOffset, context.itemOffset)
    }
    
    func initialSelectorSets(withoutIndex: Bool = false) -> SelectorSets {
        var selectorSets = SelectorSets()
        selectorSets.withoutIndex = withoutIndex
        
        #if os(iOS) || os(tvOS)
        scrollViewDelegates.add(by: &selectorSets)
        collectionViewDataSources.add(by: &selectorSets)
        collectionViewDelegates.add(by: &selectorSets)
        collectionViewDelegateFlowLayouts.add(by: &selectorSets)
        tableViewDataSources.add(by: &selectorSets)
        tableViewDelegates.add(by: &selectorSets)
        #endif
        
        return selectorSets
    }
    
    func apply<Object: AnyObject, Output>(
        _ keyPath: KeyPath<BaseCoordinator, Delegate<Object, Void, Output>>,
        object: Object
    ) -> Output {
        apply(keyPath, object: object, with: ())
    }
    
    func apply<Object: AnyObject>(
        _ keyPath: KeyPath<BaseCoordinator, Delegate<Object, Void, Void>>,
        object: Object
    ) {
        apply(keyPath, object: object, with: ())
    }
    
    func set<Object: AnyObject, Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<BaseCoordinator, Delegate<Object, Input, Output>>,
        _ closure: @escaping ((Object, Input)) -> Output
    ) {
        self[keyPath: keyPath].closure = { closure(($0, $1)) }
        let delegate = self[keyPath: keyPath]
        switch delegate.index {
        case .none: selectorSets.value.remove(delegate.selector)
        case .index: selectorSets.withIndex.remove(delegate.selector)
        case .indexPath: selectorSets.withIndexPath.remove(delegate.selector)
        }
    }

    func set<Object: AnyObject, Input>(
        _ keyPath: ReferenceWritableKeyPath<BaseCoordinator, Delegate<Object, Input, Void>>,
        _ closure: @escaping ((Object, Input)) -> Void
    ) {
        self[keyPath: keyPath].closure = { closure(($0, $1)) }
        let delegate = self[keyPath: keyPath]
        selectorSets.void.remove(delegate.selector)
    }
}

extension BaseCoordinator.SourceValue: DiffEquatable {
    func diffEqual(to other: Self, default value: Bool) -> Bool {
        switch (self, other) {
        case let (.single(lhs), .single(rhs)): return lhs.diffEqual(to: rhs)
        case let (.multiple(lhs), .multiple(rhs)): return lhs.diffEqual(to: rhs)
        case let (.inSource(lhs), .inSource(rhs)): return lhs.diffEqual(to: rhs, default: true)
        case let (.other(lhs), .other(rhs)): return lhs.diffEqual(to: rhs)
        default: return value
        }
    }
}

extension BaseCoordinator.DiffableValue: DiffEquatable {
    func diffEqual(to other: Self, default value: Bool) -> Bool {
        diffable.diffEqual(to: other.diffable, default: value)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(diffable)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.diffable == rhs.diffable
    }
}

extension BaseCoordinator.DiffableSource: DiffEquatable {
    func diffEqual(to other: Self, default value: Bool) -> Bool {
        diffableValue.diffEqual(to: other.diffableValue, default: value)
            && associatedDiffEqual(self, other)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(diffableValue)
        associatedHashInto(self, &hasher)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.diffableValue == rhs.diffableValue && lhs.associatedEqual(lhs, rhs)
    }
}

extension BaseCoordinator.DiffableValue {
    init<Source: DataSource>(
        source: Source,
        differ: Differ<Source.SourceBase>,
        coordinator: Coordinator
    ) {
        let diffable = Diffable<Any>(
            type: coordinator.selfType,
            differ: .init(differ: differ),
            value: { source.sourceBase }
        )
        self.init(diffable: diffable, coordinator: coordinator) { source }
    }
}

extension BaseCoordinator.DiffableSource {
    init<Source: DataSource>(
        source: Source,
        coordinator: Coordinator,
        associatedValue: @escaping () -> AssociatedValue = { fatalError() }
    ) {
        let updater = source.updater
        self.diffableValue = .init(source: source, differ: updater.source, coordinator: coordinator)
        self.associatedValue = associatedValue
        self.associatedDiffer = .init(differ: updater.item)
    }
}

extension BaseCoordinator.DiffableSource {
    init<Source: DataSource>(
        source: Source,
        coordinator: Coordinator,
        associatedValue: @escaping () -> AssociatedValue = { fatalError() }
    ) where Source.SourceBase.Item == AssociatedDiffValue {
        let updater = source.updater
        self.diffableValue = .init(source: source, differ: updater.source, coordinator: coordinator)
        self.associatedValue = associatedValue
        self.associatedDiffer = updater.item
    }
}

extension BaseCoordinator.DiffableSource where AssociatedValue == AssociatedDiffValue {
    init<Source: DataSource>(
        item source: Source,
        coordinator: Coordinator,
        associatedValue: @escaping () -> AssociatedValue = { fatalError() }
    ) {
        self.init(source: source, coordinator: coordinator, associatedValue: associatedValue)
        self.associatedDiffEqual = { (lhs, rhs) -> Bool in
            guard let differ = lhs.associatedDiffer else { return true }
            return differ.diffEqual(lhs: lhs.associatedValue, rhs: rhs.associatedValue)
        }
        self.associatedEqual = { (lhs, rhs) -> Bool in
            guard let differ = lhs.associatedDiffer else { return true }
            return differ.equal(lhs: lhs.associatedValue, rhs: rhs.associatedValue)
        }
        self.associatedHashInto = { (lhs, hasher) in
            lhs.associatedDiffer?.hash(value: lhs.associatedValue, into: &hasher)
        }
    }
}

extension BaseCoordinator.DiffableSource where AssociatedValue == AssociatedDiffValue {
    init<Source: DataSource>(
        item source: Source,
        coordinator: Coordinator,
        associatedValue: @escaping () -> AssociatedValue = { fatalError() }
    ) where Source.SourceBase.Item == AssociatedDiffValue {
        self.init(source: source, coordinator: coordinator, associatedValue: associatedValue)
        self.associatedDiffEqual = { (lhs, rhs) -> Bool in
            guard let differ = lhs.associatedDiffer else { return true }
            return differ.diffEqual(lhs: lhs.associatedValue, rhs: rhs.associatedValue)
        }
        self.associatedEqual = { (lhs, rhs) -> Bool in
            guard let differ = lhs.associatedDiffer else { return true }
            return differ.equal(lhs: lhs.associatedValue, rhs: rhs.associatedValue)
        }
        self.associatedHashInto = { (lhs, hasher) in
            lhs.associatedDiffer?.hash(value: lhs.associatedValue, into: &hasher)
        }
    }
}

extension BaseCoordinator.Other: DiffEquatable {
    func diffEqual(to other: Self, default value: Bool) -> Bool {
        switch (self.type, other.type) {
        case (.cellContainer, .cellContainer):
            return true
        case (.noneDiffable, .noneDiffable):
            let (lhs, rhs) = (diffable(), other.diffable())
            return lhs.coordinator.sourceIndices == rhs.coordinator.sourceIndices &&
                lhs.diffEqual(to: rhs)
        default:
            return value
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        if type == .noneDiffable {
            hasher.combine(diffable())
        }
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs.type, rhs.type) {
        case (.cellContainer, .cellContainer): return true
        case (.noneDiffable, .noneDiffable): return lhs.diffable() == rhs.diffable()
        default: return false
        }
    }
}

extension BaseCoordinator.SourceIndices {
    var count: Int {
        switch self {
        case let .section(_, count): return count
        case let .cell(cells): return cells.count
        }
    }
}
