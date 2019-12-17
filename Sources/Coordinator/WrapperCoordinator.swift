//
//  WrapperCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

class WrapperCoordinator<SourceBase: DataSource>: ListCoordinator<SourceBase> {
    var wrappedCoodinator: BaseCoordinator { fatalError() }
    
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
        listView: SetuptableListView,
        objectIdentifier: ObjectIdentifier,
        sectionOffset: Int = 0,
        itemOffset: Int = 0,
        isRoot: Bool = false
    ) -> Delegates {
        let subdelegates = wrappedCoodinator.setup(
            listView: listView,
            objectIdentifier: objectIdentifier,
            sectionOffset: sectionOffset,
            itemOffset: itemOffset
        )
        
        let delegates = delegatesStorage[objectIdentifier] ?? {
            let delegates = SourceDelegates(
                coordinator: self as ListCoordinator<SourceBase>,
                other: subdelegates,
                listView: listView
            )
            delegatesStorage[objectIdentifier] = delegates
            stagingDelegatesSetups.forEach { $0(delegates) }
            delegates.setupSelectorSets()
            return delegates
        }()
        delegates.sectionOffset = sectionOffset
        delegates.itemOffset = itemOffset
        if isRoot { listView.setup(with: delegates) }
        return delegates
    }
}
