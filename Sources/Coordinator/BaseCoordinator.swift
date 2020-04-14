//
//  BaseCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/10/12.
//

final class ItemRelatedCache {
    var nestedAdapterItemUpdate = [AnyHashable: (Bool, (Any) -> Void)]()
    var cacheForItem = [ObjectIdentifier: Any]()
}

public class BaseCoordinator {
    enum SourceType {
        case cell
        case section
    }
    
    enum SourceMultipleType {
        case single
        case multiple
        case sources
        case noneDiffable
    }
    
    lazy var selectorSets = initialSelectorSets()
    
    #if os(iOS) || os(tvOS)
    lazy var scrollListDelegate = UIScrollListDelegate()
    lazy var collectionListDelegate = UICollectionListDelegate()
    lazy var tableListDelegate = UITableListDelegate()
    #endif
    
    //Source Diffing
    var didUpdateToCoordinator = [(BaseCoordinator, BaseCoordinator) -> Void]()
    var didUpdateIndices = [() -> Void]()
    
    var id: AnyHashable { fatalError() }
    
    var sourceType = SourceType.cell
    var multiType: SourceMultipleType { .sources }
    var isEmpty: Bool { false }
    
    func anyItem(at path: PathConvertible) -> Any { fatalError() }
    func itemRelatedCache(at path: PathConvertible) -> ItemRelatedCache { fatalError() }
    
    func numbersOfSections() -> Int { fatalError() }
    func numbersOfItems(in section: Int) -> Int { fatalError() }
    
    func setup(
        listView: ListView,
        key: ObjectIdentifier,
        sectionOffset: Int = 0,
        itemOffset: Int = 0,
        supercoordinator: BaseCoordinator? = nil
    ) {
        fatalError()
    }
    
    func update(
        from coordinator: BaseCoordinator,
        animated: Bool,
        completion: ((Bool) -> Void)?) -> Bool {
        fatalError()
    }
    
    //Diffs
    func itemDifference<Value>(
        from coordinator: BaseCoordinator,
        differ: Differ<Value>
    ) -> [Difference<ItemRelatedCache>] {
        fatalError()
    }
    
    func itemsDifference<Value>(
        from coordinator: BaseCoordinator,
        differ: Differ<Value>
    ) -> Difference<Void> {
        fatalError()
    }
    
    func sourcesDifference<Value>(
        from coordinator: BaseCoordinator,
        differ: Differ<Value>
    ) -> Difference<BaseCoordinator> {
        fatalError()
    }
    
    //Selectors
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
    
    func initialSelectorSets(withoutIndex: Bool = false) -> SelectorSets {
        var selectorSets = SelectorSets()
        selectorSets.withoutIndex = withoutIndex
        
        #if os(iOS) || os(tvOS)
        scrollListDelegate.add(by: &selectorSets)
        collectionListDelegate.add(by: &selectorSets)
        tableListDelegate.add(by: &selectorSets)
        #endif
        
        return selectorSets
    }
}
