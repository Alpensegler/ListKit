//
//  ListCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/11/25.
//

public class ListCoordinator: Coordinator {
    enum SourceValue<OtherType, Coordinator, AssociatedValue, AssociatedDiffValue>
    where Coordinator: ListCoordinator, OtherType: DiffEquatable {
        case single(DiffableSource<Coordinator, AssociatedValue, AssociatedDiffValue>)
        case multiple(DiffableSource<Coordinator, [AssociatedValue], AssociatedDiffValue>)
        case inSource(DiffableSource<Coordinator, [Self], AssociatedDiffValue>)
        case other(OtherType)
    }
    
    struct DiffableValue<Coordinator: ListCoordinator> {
        let diffable: Diffable<Any>
        var coordinator: Coordinator
        var value: () -> Any
    }
    
    struct DiffableSource<Coordinator: ListCoordinator, AssociatedValue, AssociatedDiffValue> {
        let diffableValue: DiffableValue<Coordinator>
        var associatedValue: () -> AssociatedValue = { fatalError() }
        var associatedDiffer: Differ<AssociatedDiffValue>?
        
        var associatedDiffEqual: (Self, Self) -> Bool = { _, _ in true }
        var associatedEqual: (Self, Self) -> Bool = { _, _ in true }
        var associatedHashInto: (Self, inout Hasher) -> Void = { _, _ in }
    }
    
    struct Other<Coordinator: ListCoordinator, AssociatedValue, AssociatedDiffValue> {
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
    
    enum SourceType {
        case cell
        case section
    }
    
    enum SourceIndices: Equatable {
        case section(index: Int, count: Int)
        case cell(indices: [Int])
    }
    
    typealias SectionSourceValue<C: ListCoordinator, A, D> = SourceValue<Other<C, A, D>, C, A, D>
    
    typealias AnyItemSources = SourceValue<Never, ListCoordinator, Any, Any>
    typealias AnySectionSources = SectionSourceValue<ListCoordinator, [Any], Any>
    typealias AnyDiffableSourceValue = DiffableValue<ListCoordinator>
    
    var selfType = TypeHashable(type: Any.self)
    var itemType = TypeHashable(type: Any.self)
    
    var sourceType = SourceType.cell
    var sourceIndices = [SourceIndices]()
    var rangeReplacable = false
    
    override func numbersOfSections() -> Int { sourceIndices.count }
    override func numbersOfItems(in section: Int) -> Int { sourceIndices[section].count }
    
    func anyItem(at path: Path) -> Any { fatalError() }
    
    func anyItemSources<Source: DataSource>(source: Source) -> AnyItemSources { fatalError() }
    func anyItemApplyMultiItem(changes: ValueChanges<Any, Int>) { fatalError() }
    
    func anySectionSources<Source: DataSource>(source: Source) -> AnySectionSources { fatalError() }
    func anySectionApplyMultiSection(changes: ValueChanges<[Any], Int>) { fatalError() }
    func anySectionApplyItem(changes: [ValueChanges<Any, Int>]) { fatalError() }
    
    func anySourceUpdate(to sources: [AnyDiffableSourceValue]) { fatalError() }
    
    func update(
        from coordinator: ListCoordinator,
        fromOffset: Path,
        toOffset: Path,
        isMove: Bool
    ) -> [(changes: ListChanges, update: () -> Void)] {
        fatalError()
    }
}

public class ItemListCoordinator<Item>: ListCoordinator {
    typealias ItemSource = SourceValue<Never, ItemListCoordinator<Item>, Item, Item>
    typealias SectionSource = SectionSourceValue<ItemListCoordinator<Item>, [Item], Item>
    typealias DiffableSourceValue = DiffableValue<ItemListCoordinator<Item>>
    
    var itemDiffable = false
    var sectionDiffable = false
    
    func item(at path: Path) -> Item { fatalError() }
    
    func itemSources<Source: DataSource>(source: Source) -> ItemSource
        where Source.SourceBase.Item == Item { fatalError() }
    func itemApplyMultiItem(changes: ValueChanges<Item, Int>) { fatalError() }
    
    func sectionSources<Source: DataSource>(source: Source) -> SectionSource
        where Source.SourceBase.Item == Item { fatalError() }
    func sectionApplyMultiSection(changes: ValueChanges<[Item], Int>) { fatalError() }
    func sectionApplyItem(changes: [ValueChanges<Item, Int>]) { fatalError() }
    
    func sourceUpdate(to sources: [DiffableSourceValue]) { fatalError() }
    
    override func anyItem(at path: Path) -> Any { item(at: path) }
}

public class SourceListCoordinator<Source: DataSource>: ItemListCoordinator<Source.Item> {
    typealias Item = Source.Item
    
    var source: Source.Source
    
    func setup() { }
    
    init(value: Source) {
        self.source = value.source
        
        super.init()
        
        selfType = TypeHashable(type: Source.self)
        itemType = TypeHashable(type: Source.Item.self)
        setup()
    }
}

extension ListCoordinator.SourceValue: DiffEquatable {
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

extension ListCoordinator.DiffableValue: DiffEquatable {
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

extension ListCoordinator.DiffableSource: DiffEquatable {
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

extension ListCoordinator.DiffableValue {
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

extension ListCoordinator.DiffableSource {
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

extension ListCoordinator.DiffableSource {
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

extension ListCoordinator.DiffableSource where AssociatedValue == AssociatedDiffValue {
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

extension ListCoordinator.DiffableSource where AssociatedValue == AssociatedDiffValue {
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

extension ListCoordinator.Other: DiffEquatable {
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

extension ListCoordinator.SourceIndices {
    var count: Int {
        switch self {
        case let .section(_, count): return count
        case let .cell(cells): return cells.count
        }
    }
}
