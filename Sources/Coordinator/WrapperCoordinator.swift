//
//  WrapperCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

class WrapperCoordinator<SourceBase: DataSource, OtherSourceBase: DataSource>: ListCoordinator<SourceBase>
where SourceBase.SourceBase == SourceBase, OtherSourceBase.SourceBase == OtherSourceBase {
    var wrappedCoodinator: ListCoordinator<OtherSourceBase>
    var itemTransform: (OtherSourceBase.Item) -> SourceBase.Item
    var others: SelectorSets { wrappedCoodinator.selectorSets }
    var _source: SourceBase.Source
    
    lazy var combinedID = HashCombiner(_id, wrappedCoodinator.id)
    lazy var selfSelectorSets = initialSelectorSets()
    
    override var id: AnyHashable { combinedID }
    
    override var sourceType: SourceType {
        get { wrappedCoodinator.sourceType }
        set { wrappedCoodinator.sourceType = newValue }
    }
    
    override var multiType: SourceMultipleType { wrappedCoodinator.multiType }
    override var isEmpty: Bool { wrappedCoodinator.isEmpty }
    
    func subcoordinator<Object: AnyObject, Input, Output>(
        for delegate: Delegate<Object, Input, Output>,
        object: Object,
        with input: Input
    ) -> BaseCoordinator? {
        others.contains(delegate.selector) ? nil : wrappedCoodinator
    }
    
    override func configNestedIfNeeded() {
        wrappedCoodinator.configNestedIfNeeded()
    }
    
    override func configNestedNotNewIfNeeded() {
        wrappedCoodinator.configNestedNotNewIfNeeded()
    }
    
    override func item(at path: PathConvertible) -> Item {
        itemTransform(wrappedCoodinator.item(at: path))
    }
    
    override func anyItem(at path: PathConvertible) -> Any {
        wrappedCoodinator.anyItem(at: path)
    }
    
    override func itemRelatedCache(at path: PathConvertible) -> ItemRelatedCache {
        wrappedCoodinator.itemRelatedCache(at: path)
    }
    
    override func numbersOfSections() -> Int {
        wrappedCoodinator.numbersOfSections()
    }
    
    override func numbersOfItems(in section: Int) -> Int {
        wrappedCoodinator.numbersOfItems(in: section)
    }
    
    //Diffs
    override func itemDifference<Value>(
        from coordinator: BaseCoordinator,
        differ: Differ<Value>
    ) -> [Difference<ItemRelatedCache>] {
        wrappedCoodinator.itemDifference(from: coordinator, differ: differ)
    }
    
    override func itemsDifference<Value>(
        from coordinator: BaseCoordinator,
        differ: Differ<Value>
    ) -> Difference<Void> {
        wrappedCoodinator.itemsDifference(from: coordinator, differ: differ)
    }
    
    override func sourcesDifference<Value>(
        from coordinator: BaseCoordinator,
        differ: Differ<Value>
    ) -> Difference<BaseCoordinator> {
        wrappedCoodinator.sourcesDifference(from: coordinator, differ: differ)
    }
    

//    override func anyItemSources<Source: DataSource>(source: Source) -> AnyItemSources {
//        wrappedCoodinator.anyItemSources(source: source)
//    }
//
//    override func anyItemApplyMultiItem(changes: ValueChanges<Any, Int>) {
//        wrappedCoodinator.anyItemApplyMultiItem(changes: changes)
//    }
//
//    override func anySectionSources<Source: DataSource>(source: Source) -> AnySectionSources {
//        wrappedCoodinator.anySectionSources(source: source)
//    }
//
//    override func anySectionApplyMultiSection(changes: ValueChanges<[Any], Int>) {
//        wrappedCoodinator.anySectionApplyMultiSection(changes: changes)
//    }
//
//    override func anySectionApplyItem(changes: [ValueChanges<Any, Int>]) {
//        wrappedCoodinator.anySectionApplyItem(changes: changes)
//    }
//
//    override func anySourceUpdate(to sources: [AnyDiffableSourceValue]) {
//        wrappedCoodinator.anySourceUpdate(to: sources)
//    }

    override func setup() {
        super.setup()
        selectorSets = SelectorSets(merging: selfSelectorSets, others)
    }
    
    override func setup(
        listView: ListView,
        key: ObjectIdentifier,
        sectionOffset: Int = 0,
        itemOffset: Int = 0,
        supercoordinator: BaseCoordinator? = nil
    ) {
        wrappedCoodinator.setup(
            listView: listView,
            key: key,
            sectionOffset: sectionOffset,
            itemOffset: itemOffset,
            supercoordinator: supercoordinator
        )
        
        super.setup(
            listView: listView,
            key: key,
            sectionOffset: sectionOffset,
            itemOffset: itemOffset,
            supercoordinator: supercoordinator
        )
    }
    
    override func selectorSets(applying: (inout SelectorSets) -> Void) {
        super.selectorSets(applying: applying)
        applying(&selfSelectorSets)
    }
    
    override func apply<Object: AnyObject, Input, Output>(
        _ keyPath: KeyPath<BaseCoordinator, Delegate<Object, Input, Output>>,
        object: Object,
        with input: Input
    ) -> Output {
        let closure = self[keyPath: keyPath]
        let coordinator = subcoordinator(for: closure, object: object, with: input)
        return coordinator?.apply(keyPath, object: object, with: input)
            ?? super.apply(keyPath, object: object, with: input)
    }
    
    override func apply<Object: AnyObject, Input>(
        _ keyPath: KeyPath<BaseCoordinator, Delegate<Object, Input, Void>>,
        object: Object,
        with input: Input
    ) {
        let closure = self[keyPath: keyPath]
        let coordinator = subcoordinator(for: closure, object: object, with: input)
        coordinator?.apply(keyPath, object: object, with: input)
        super.apply(keyPath, object: object, with: input)
    }
}
