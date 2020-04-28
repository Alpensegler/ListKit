//
//  BaseCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/10/12.
//

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

protocol Coordinator: AnyObject {
    var sourceType: SourceType { get }
    var selectorSets: SelectorSets { get }
    var isEmpty: Bool { get }
    var didSetup: Bool { get set }
    
    #if os(iOS) || os(tvOS)
    var scrollListDelegate: UIScrollListDelegate { get set }
    var collectionListDelegate: UICollectionListDelegate { get set }
    var tableListDelegate: UITableListDelegate { get set }
    #endif
    
    func numbersOfSections() -> Int
    func numbersOfItems(in section: Int) -> Int
    
    func apply<Object: AnyObject, Input, Output>(
        _ keyPath: KeyPath<Coordinator, Delegate<Object, Input, Output>>,
        object: Object,
        with input: Input
    ) -> Output
    
    func apply<Object: AnyObject, Input>(
        _ keyPath: KeyPath<Coordinator, Delegate<Object, Input, Void>>,
        object: Object,
        with input: Input
    )
    
    func setup()
    
    func setupContext(
        listView: ListView,
        key: ObjectIdentifier,
        sectionOffset: Int,
        itemOffset: Int,
        supercoordinator: Coordinator?
    )
    
    func update(
        from coordinator: Coordinator,
        animated: Bool,
        completion: ((Bool) -> Void)?
    ) -> Bool
}

extension Coordinator {
    func setupIfNeeded() {
        if didSetup { return }
        setup()
        didSetup = true
    }
    
    func setup(
        listView: ListView,
        key: ObjectIdentifier,
        sectionOffset: Int = 0,
        itemOffset: Int = 0,
        supercoordinator: Coordinator? = nil
    ) {
        setupIfNeeded()
        setupContext(
            listView: listView,
            key: key,
            sectionOffset: sectionOffset,
            itemOffset: itemOffset,
            supercoordinator: supercoordinator
        )
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
