//
//  ListContext.swift
//  ListKit
//
//  Created by Frain on 2019/12/15.
//

typealias ListContext<SourceBase: DataSource> = CoordinatorContext<ListCoordinator<SourceBase>>

class CoordinatorContext<Coordinator: BaseCoordinator>: Delegates {
    unowned let coordinator: Coordinator
    override var baseCoordinator: BaseCoordinator { coordinator }
    var sectionOffset = 0
    var itemOffset = 0
    var listView: () -> ListView? = { nil }
    
    init(coordinator: Coordinator) {
        self.coordinator = coordinator
        super.init()
    }
    
    func selectorSets(applying: (inout SelectorSets) -> Void) {
        applying(&selectorSets)
    }
    
    func set<Object: AnyObject, Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<Delegates, Delegate<Object, Input, Output>>,
        _ closure: @escaping (Coordinator, Object, Input) -> Output
    ) {
        self[keyPath: keyPath].closure = { [unowned coordinator] in closure(coordinator, $0, $1) }
        let delegate = self[keyPath: keyPath]
        switch delegate.index {
        case .none: selectorSets { $0.value.remove(delegate.selector) }
        case .index: selectorSets { $0.withIndex.remove(delegate.selector) }
        case .indexPath: selectorSets { $0.withIndexPath.remove(delegate.selector) }
        }
    }

    func set<Object: AnyObject, Input>(
        _ keyPath: ReferenceWritableKeyPath<Delegates, Delegate<Object, Input, Void>>,
        _ closure: @escaping (Coordinator, Object, Input) -> Void
    ) {
        self[keyPath: keyPath].closure = { [unowned coordinator] in closure(coordinator, $0, $1) }
        let delegate = self[keyPath: keyPath]
        selectorSets { $0.void.remove(delegate.selector) }
    }
}

class SourceContext<Coordinator: BaseCoordinator>: CoordinatorContext<Coordinator> {
    lazy var selfSelectorSets = initialSelectorSets()
    var others = SelectorSets()
    
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
}

class SourcesContext<SourceBase: DataSource>: SourceContext<SourcesCoordinator<SourceBase>>
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: DataSource,
    SourceBase.Source.Element.SourceBase.Item == SourceBase.Item
{
    var subdelegates: [(delegate: Delegates, isEmpty: Bool)] = []
    
    override func setupSelectorSets() {
        let notEmptyDelegates = subdelegates.filter { !$0.isEmpty }
        for (delegates, _) in notEmptyDelegates {
            others.withIndex.formUnion(delegates.selectorSets.withIndex)
            others.withIndexPath.formUnion(delegates.selectorSets.withIndexPath)
            others.hasIndex = others.hasIndex || delegates.selectorSets.hasIndex
        }
        super.setupSelectorSets()
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
        guard let index = delegate.index else { return nil }
        let offset: Int
        switch index {
        case let .index(keyPath):
            let section = input[keyPath: keyPath]
            guard let sectionOffset = coordinator.index(of: section - sectionOffset) else {
                return nil
            }
            offset = sectionOffset
        case let .indexPath(keyPath):
            let path = input[keyPath: keyPath]
            let rawPath = Path(section: path.section - sectionOffset, item: path.item - itemOffset)
            offset = coordinator.index(of: rawPath)
        }
        let (delegates, _) = subdelegates[offset]
        return delegates.selectorSets.contains(delegate.selector) ? nil : delegates
    }
}
