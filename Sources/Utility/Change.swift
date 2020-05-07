//
//  Change.swift
//  ListKit
//
//  Created by Frain on 2019/11/15.
//

class Change<Index: Equatable> {
    let index: Index
    var isReload = false
    var associated: Change<Index>? {
        didSet {
            if associated?.associated === self { return }
            associated?.associated = self
        }
    }
    
    init(index: Index) {
        self.index = index
    }
}

class DiffChange<Cache, Index: Equatable>: Change<Index> {
    var cache: Diffable<Cache> { fatalError() }
    var diffable: Diffable<Cache>
    var diffAssociated: DiffChange<Cache, Index>? {
        didSet {
            if diffAssociated?.diffAssociated === self { return }
            associated = diffAssociated
            diffAssociated?.diffAssociated = self
        }
    }
    
    init(diffable: Diffable<Cache>, index: Index) {
        self.diffable = diffable
        super.init(index: index)
    }
}

final class ValueChange<Value, Cache, Index: Equatable>: DiffChange<Cache, Index> {
    var value: DiffableValue<Value, Cache>
    var differ: Differ<Value>
    var valueAssociated: ValueChange<Value, Cache, Index>? {
        didSet {
            if valueAssociated?.valueAssociated === self { return }
            diffAssociated = valueAssociated
            valueAssociated?.valueAssociated = self
        }
    }
    
    override var cache: Diffable<Cache> { value }
    
    init(_ value: DiffableValue<Value, Cache>, differ: Differ<Value>?, index: Index) {
        self.value = value
        self.differ = differ ?? value.differ
        super.init(diffable: value, index: index)
    }
}


//class Updates<Cache> {
//    private(set) var first: Difference<Cache>
//    private(set) var second: Difference<Cache>
//
//    var firstChange = { }
//    var secondChange = { }
//
//    init(first: Difference<Cache> = .init(), second: Difference<Cache> = .init()) {
//        self.first = first
//        self.second = second
//    }
//}
//
//final class ValueUpdates<Value, Cache>: Updates<Cache> {
//    override var first: Difference<Cache> { firstDiff }
//    override var second: Difference<Cache> { secondDiff }
//
//    var firstDiff: ValueDifference<Value, Cache>
//    var secondDiff: ValueDifference<Value, Cache>
//
//    init(
//        firstDiff: ValueDifference<Value, Cache>,
//        secondDiff: ValueDifference<Value, Cache>
//    ) {
//        self.firstDiff = firstDiff
//        self.secondDiff = secondDiff
//        super.init()
//    }
//}
//
//class ListChangesClass {
//    var itemUpdates: Updates<Path, ItemRelatedCache?> { fatalError() }
//    var elementUpdates: Updates<Int, BaseCoordinator> { fatalError() }
//}
//
//final class ListValueChanges<Item, Element>: ListChangesClass {
//    override var itemUpdates: Updates<Path, ItemRelatedCache?> { itemUpdatesValue }
//    override var elementUpdates: Updates<Int, BaseCoordinator> { elementUpdatesValue }
//
//    var itemUpdatesValue: ValueUpdates<Item, Path, ItemRelatedCache?>
//    var elementUpdatesValue: ValueUpdates<Element, Int, BaseCoordinator>
//
//    init(
//        itemUpdatesValue: ValueUpdates<Item, Path, ItemRelatedCache?> = .init(),
//        elementUpdatesValue: ValueUpdates<Element, Int, BaseCoordinator> = .init()
//    ) {
//        self.itemUpdatesValue = itemUpdatesValue
//        self.elementUpdatesValue = elementUpdatesValue
//    }
//}
//
//typealias AnyItemChange = DiffChange<ItemRelatedCache?>
//typealias AnyItemsChange = DiffChange<Void>
//typealias AnyElementChange = DiffChange<BaseCoordinator>
//
//typealias ItemChange<Item> = ValueChangeClass<Item, ItemRelatedCache?>
//typealias ItemsChange<Item> = ValueChangeClass<[Item], Void>
//typealias ElementChange<Element> = ValueChangeClass<Element, BaseCoordinator>
