//
//  WrapperCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

final class WrapperCoordinator<SourceBase: DataSource, OtherSourceBase>: ListCoordinator<SourceBase>
where SourceBase.SourceBase == SourceBase, OtherSourceBase: DataSource {
    var wrappedCoodinator: ListCoordinator<OtherSourceBase.SourceBase>
    var itemTransform: (OtherSourceBase.Item) -> SourceBase.Item
    var others: SelectorSets { wrappedCoodinator.selectorSets }
    
    lazy var selfSelectorSets = initialSelectorSets()
    
    override var multiType: SourceMultipleType { wrappedCoodinator.multiType }
    override var isEmpty: Bool { wrappedCoodinator.isEmpty }
    
    init(
        source: SourceBase.Source,
        wrappedCoodinator: ListCoordinator<OtherSourceBase.SourceBase>,
        storage: CoordinatorStorage<SourceBase>? = nil,
        itemTransform: @escaping (OtherSourceBase.Item) -> SourceBase.Item
    ) {
        self.wrappedCoodinator = wrappedCoodinator
        self.itemTransform = itemTransform
        super.init(
            id: HashCombiner(ObjectIdentifier(SourceBase.self), ObjectIdentifier(OtherSourceBase.self)),
            source: source,
            storage: storage
        )
    }
    
    func subcoordinator<Object: AnyObject, Input, Output>(
        for delegate: Delegate<Object, Input, Output>,
        object: Object,
        with input: Input
    ) -> Coordinator? {
        others.contains(delegate.selector) ? nil : wrappedCoodinator
    }
    
    override func configNestedIfNeeded() {
        wrappedCoodinator.configNestedIfNeeded()
    }
    
    override func configNestedNotNewIfNeeded() {
        wrappedCoodinator.configNestedNotNewIfNeeded()
    }
    
    override func item(at path: Path) -> Item {
        itemTransform(wrappedCoodinator.item(at: path))
    }
    
    override func itemRelatedCache(at path: Path) -> ItemRelatedCache {
        wrappedCoodinator.itemRelatedCache(at: path)
    }
    
    override func numbersOfSections() -> Int {
        wrappedCoodinator.numbersOfSections()
    }
    
    override func numbersOfItems(in section: Int) -> Int {
        wrappedCoodinator.numbersOfItems(in: section)
    }

    override func setup() {
        wrappedCoodinator.setupIfNeeded()
        selectorSets = SelectorSets(merging: selfSelectorSets, others)
        sourceType = (wrappedCoodinator.sourceType == .section || selectorSets.hasIndex) ? .section : wrappedCoodinator.sourceType
    }
    
    override func setupContext(
        listView: ListView,
        key: ObjectIdentifier,
        sectionOffset: Int = 0,
        itemOffset: Int = 0,
        supercoordinator: Coordinator? = nil
    ) {
        wrappedCoodinator.setupContext(
            listView: listView,
            key: key,
            sectionOffset: sectionOffset,
            itemOffset: itemOffset,
            supercoordinator: supercoordinator
        )
        
        super.setupContext(
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
        _ keyPath: KeyPath<Coordinator, Delegate<Object, Input, Output>>,
        object: Object,
        with input: Input
    ) -> Output {
        let closure = self[keyPath: keyPath]
        let coordinator = subcoordinator(for: closure, object: object, with: input)
        return coordinator?.apply(keyPath, object: object, with: input)
            ?? super.apply(keyPath, object: object, with: input)
    }
    
    override func apply<Object: AnyObject, Input>(
        _ keyPath: KeyPath<Coordinator, Delegate<Object, Input, Void>>,
        object: Object,
        with input: Input
    ) {
        let closure = self[keyPath: keyPath]
        let coordinator = subcoordinator(for: closure, object: object, with: input)
        coordinator?.apply(keyPath, object: object, with: input)
        super.apply(keyPath, object: object, with: input)
    }
}

extension WrapperCoordinator
where
    SourceBase.Source == OtherSourceBase,
    SourceBase.Item == OtherSourceBase.Item
{
    convenience init(wrapperSourceBase sourceBase: SourceBase, storage: CoordinatorStorage<SourceBase>? = nil) {
        let source = sourceBase.source(storage: storage)
        self.init(
            source: source,
            wrappedCoodinator: source.makeListCoordinator(),
            storage: storage
        ) { $0 }
    }
}

extension WrapperCoordinator
where
    SourceBase.Source == OtherSourceBase,
    SourceBase.Item == OtherSourceBase.Item,
    SourceBase: UpdatableDataSource
{
    
    convenience init(updatableWrapper sourceBase: SourceBase) {
        self.init(wrapperSourceBase: sourceBase, storage: sourceBase.coordinatorStorage)
    }
}
