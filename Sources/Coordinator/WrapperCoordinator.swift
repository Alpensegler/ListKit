//
//  WrapperCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

class WrapperCoordinator<SourceBase: DataSource>: ListCoordinator<SourceBase> {
    var wrappedCoodinator: BaseCoordinator { fatalError() }
    
    lazy var selfSelectorSets = initialSelectorSets()
    var others: SelectorSets { wrappedCoodinator.selectorSets }
    
    override var itemType: ObjectIdentifier {
        get { wrappedCoodinator.itemType }
        set { wrappedCoodinator.itemType = newValue }
    }
    
    override var sourceType: SourceType {
        get { wrappedCoodinator.sourceType }
        set { wrappedCoodinator.sourceType = newValue }
    }
    
    override var sourceIndices: [SourceIndices] {
        get { wrappedCoodinator.sourceIndices }
        set { wrappedCoodinator.sourceIndices = newValue }
    }
    
    override var rangeReplacable: Bool {
        get { wrappedCoodinator.rangeReplacable }
        set { wrappedCoodinator.rangeReplacable = newValue }
    }
    
    override func anyItem<Path: PathConvertible>(at path: Path) -> Any {
        wrappedCoodinator.anyItem(at: path)
    }
    
    override func anyItemSources<Source: DataSource>(source: Source) -> AnyItemSources {
        wrappedCoodinator.anyItemSources(source: source)
    }
    
    override func anyItemApplyMultiItem(changes: ValueChanges<Any, Int>) {
        wrappedCoodinator.anyItemApplyMultiItem(changes: changes)
    }
    
    override func anySectionSources<Source: DataSource>(source: Source) -> AnySectionSources {
        wrappedCoodinator.anySectionSources(source: source)
    }
    
    override func anySectionApplyMultiSection(changes: ValueChanges<[Any], Int>) {
        wrappedCoodinator.anySectionApplyMultiSection(changes: changes)
    }
    
    override func anySectionApplyItem(changes: [ValueChanges<Any, Int>]) {
        wrappedCoodinator.anySectionApplyItem(changes: changes)
    }
    
    override func anySourceUpdate(to sources: [AnyDiffableSourceValue]) {
        wrappedCoodinator.anySourceUpdate(to: sources)
    }
    
    override func setup(
        listView: ListView,
        key: ObjectIdentifier,
        sectionOffset: Int = 0,
        itemOffset: Int = 0
    ) {
        wrappedCoodinator.setup(
            listView: listView,
            key: key,
            sectionOffset: sectionOffset,
            itemOffset: itemOffset
        )
        
        super.setup(
            listView: listView,
            key: key,
            sectionOffset: sectionOffset,
            itemOffset: itemOffset
        )
    }
    
    override func setup() {
        super.setup()
        selectorSets = SelectorSets(merging: selfSelectorSets, others)
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
    
    func subcoordinator<Object: AnyObject, Input, Output>(
        for delegate: Delegate<Object, Input, Output>,
        object: Object,
        with input: Input
    ) -> BaseCoordinator? {
        others.contains(delegate.selector) ? nil : wrappedCoodinator
    }
}
