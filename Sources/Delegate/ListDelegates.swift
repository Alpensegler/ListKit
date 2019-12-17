//
//  ListContext.swift
//  ListKit
//
//  Created by Frain on 2019/12/15.
//

class ListDelegates<SourceBase: DataSource>: Delegates {
    unowned let coordinator: ListCoordinator<SourceBase>
    override var baseCoordinator: BaseCoordinator { coordinator }
    var listView: () -> SetuptableListView?
    
    init(coordinator: ListCoordinator<SourceBase>, listView: SetuptableListView) {
        self.coordinator = coordinator
        self.listView = { [weak listView] in listView }
        super.init()
    }
    
    func setup(isRoot: Bool, listView: SetuptableListView) {
        self.isRoot = isRoot
        guard isRoot else { return }
        listView.setup(with: self)
    }
    
    func selectorSets(applying: (inout SelectorSets) -> Void) {
        applying(&selectorSets)
    }
    
    func set<Object: AnyObject, Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<Delegates, Delegate<Object, Input, Output>>,
        _ closure: @escaping (ListDelegates<SourceBase>, Object, Input) -> Output
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
        _ closure: @escaping (ListDelegates<SourceBase>, Object, Input) -> Void
    ) {
        self[keyPath: keyPath].closure = { [unowned self] in closure(self, $0, $1) }
        let delegate = self[keyPath: keyPath]
        selectorSets { $0.void.remove(delegate.selector) }
    }
}
