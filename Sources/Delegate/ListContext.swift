//
//  ListContext.swift
//  ListKit
//
//  Created by Frain on 2019/12/15.
//

class ListContext<SourceBase: DataSource>: Delegates {
    unowned let coordinator: ListCoordinator<SourceBase>
    override var baseCoordinator: BaseCoordinator { coordinator }
    var listView: () -> SetuptableListView?
    
    init(coordinator: ListCoordinator<SourceBase>, listView: SetuptableListView) {
        self.coordinator = coordinator
        self.listView = { [weak listView] in listView }
        super.init()
    }
    
    func selectorSets(applying: (inout SelectorSets) -> Void) {
        applying(&selectorSets)
    }
    
    func set<Object: AnyObject, Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<Delegates, Delegate<Object, Input, Output>>,
        _ closure: @escaping (ListContext<SourceBase>, Object, Input) -> Output
    ) {
        self[keyPath: keyPath].closure = { [unowned self] in closure(self, $0, $1) }
        let delegate = self[keyPath: keyPath]
        switch delegate.index {
        case .none: selectorSets { $0.value.remove(delegate.selector) }
        case .index: selectorSets { $0.withIndex.remove(delegate.selector) }
        case .indexPath: selectorSets { $0.withIndexPath.remove(delegate.selector) }
        }
    }

    func set<Object: AnyObject, Input>(
        _ keyPath: ReferenceWritableKeyPath<Delegates, Delegate<Object, Input, Void>>,
        _ closure: @escaping (ListContext<SourceBase>, Object, Input) -> Void
    ) {
        self[keyPath: keyPath].closure = { [unowned self] in closure(self, $0, $1) }
        let delegate = self[keyPath: keyPath]
        selectorSets { $0.void.remove(delegate.selector) }
    }
}

class WrapperContext<SourceBase: DataSource>: ListContext<SourceBase> {
    lazy var selfSelectorSets = initialSelectorSets()
    var others: SelectorSets { fatalError() }
    
    func setupSelectorSets() {
        selectorSets = SelectorSets(
            void: selfSelectorSets.void.intersection(others.void),
            value: selfSelectorSets.value.intersection(others.value),
            withIndex: selfSelectorSets.withIndex.intersection(others.withIndex),
            withIndexPath: selfSelectorSets.withIndexPath.intersection(others.withIndexPath),
            hasIndex: selfSelectorSets.hasIndex || others.hasIndex
        )
    }
    
    override func selectorSets(applying: (inout SelectorSets) -> Void) {
        super.selectorSets(applying: applying)
        applying(&selfSelectorSets)
    }
    
    override func apply<Object: AnyObject, Input, Output>(
        _ keyPath: KeyPath<Delegates, Delegate<Object, Input, Output>>,
        object: Object,
        with input: Input
    ) -> Output {
        let closure = self[keyPath: keyPath]
        let delegates = subdelegates(for: closure, object: object, with: input)
        return delegates?.apply(keyPath, object: object, with: input)
            ?? super.apply(keyPath, object: object, with: input)
    }
    
    override func apply<Object: AnyObject, Input>(
        _ keyPath: KeyPath<Delegates, Delegate<Object, Input, Void>>,
        object: Object,
        with input: Input
    ) {
        let closure = self[keyPath: keyPath]
        let delegates = subdelegates(for: closure, object: object, with: input)
        delegates?.apply(keyPath, object: object, with: input)
        super.apply(keyPath, object: object, with: input)
    }
    
    func subdelegates<Object: AnyObject, Input, Output>(
        for delegate: Delegate<Object, Input, Output>,
        object: Object,
        with input: Input
    ) -> Delegates? {
        fatalError()
    }
}

class SourceContext<SourceBase: DataSource>: WrapperContext<SourceBase> {
    let otherDelegate: Delegates
    override var others: SelectorSets { otherDelegate.selectorSets }
    
    init(
        coordinator: ListCoordinator<SourceBase>,
        other: Delegates,
        listView: SetuptableListView
    ) {
        self.otherDelegate = other
        super.init(coordinator: coordinator, listView: listView)
    }
    
    override func subdelegates<Object: AnyObject, Input, Output>(
        for delegate: Delegate<Object, Input, Output>,
        object: Object,
        with input: Input
    ) -> Delegates? {
        others.contains(delegate.selector) ? nil : otherDelegate
    }
}

class SourcesContext<SourceBase: DataSource>: WrapperContext<SourceBase>
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: DataSource,
    SourceBase.Source.Element.SourceBase.Item == SourceBase.Item
{
    var subdelegates = [(delegate: Delegates, isEmpty: Bool)]()
    var _others = SelectorSets()
    override var others: SelectorSets { _others }
    
    override func setupSelectorSets() {
        _others = initialSelectorSets(withoutIndex: true)
        for (delegates, isEmpty) in subdelegates where isEmpty == false {
            others.withIndex.formUnion(delegates.selectorSets.withIndex)
            others.withIndexPath.formUnion(delegates.selectorSets.withIndexPath)
            others.hasIndex = others.hasIndex || delegates.selectorSets.hasIndex
        }
        super.setupSelectorSets()
    }
    
    func configSubdelegatesOffsets() {
        for ((delegates, _), offset) in zip(subdelegates, coordinator.offsets) {
            delegates.sectionOffset = offset.section + sectionOffset
            delegates.itemOffset = offset.item + itemOffset
        }
    }
    
    override func subdelegates<Object: AnyObject, Input, Output>(
        for delegate: Delegate<Object, Input, Output>,
        object: Object,
        with input: Input
    ) -> Delegates? {
        guard let index = delegate.index else { return nil }
        let offset: Int
        switch index {
        case let .index(keyPath):
            let section = input[keyPath: keyPath]
            guard let index = coordinator.sourceIndices.index(of: section - sectionOffset) else {
                return nil
            }
            offset = index
        case let .indexPath(keyPath):
            let path = input[keyPath: keyPath]
            let index = Path(section: path.section - sectionOffset, item: path.item - itemOffset)
            offset = coordinator.sourceIndices.index(of: index)
        }
        let (delegates, _) = subdelegates[offset]
        return delegates.selectorSets.contains(delegate.selector) ? nil : delegates
    }
}
