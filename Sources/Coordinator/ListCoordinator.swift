//
//  ListCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/11/25.
//

public class ListCoordinator<SourceBase: DataSource> where SourceBase.SourceBase == SourceBase {
    typealias Item = SourceBase.Item
    typealias Indices = ContiguousArray<(index: Int, isFake: Bool)>

    struct WeakContext {
        weak var context: ListCoordinatorContext<SourceBase>?
    }
    
    let update: ListUpdate<SourceBase>.Whole
    let differ: ListDiffer<SourceBase>
    let options: ListOptions<SourceBase>
    var source: SourceBase.Source!
    
    weak var storage: CoordinatorStorage<SourceBase>?
    weak var currentCoordinatorUpdate: CoordinatorUpdate?
    var listContexts = [WeakContext]()
    
    lazy var sectioned = isSectioned()
    
    var isEmpty: Bool { false }
    var sourceBaseType: Any.Type { SourceBase.self }
    
    init(
        source: SourceBase.Source!,
        update: ListUpdate<SourceBase>.Whole,
        differ: ListDiffer<SourceBase> = .none,
        options: ListOptions<SourceBase> = .none
    ) {
        self.update = update
        self.differ = differ
        self.options = options
        self.source = source
    }
    
    init(_ sourceBase: SourceBase) {
        self.differ = sourceBase.listDiffer
        self.update = sourceBase.listUpdate
        self.options = sourceBase.listOptions
        self.source = sourceBase.source
    }
    
    func numbersOfSections() -> Int { fatalError() }
    func numbersOfItems(in section: Int) -> Int { fatalError() }
    
    func item(at section: Int, _ item: Int) -> Item { fatalError() }
    
    func isSectioned() -> Bool {
        listContexts.contains { $0.context?.selectorSets.hasIndex == true }
    }
    
    func context(
        with setups: [(ListCoordinatorContext<SourceBase>) -> Void] = []
    ) -> ListCoordinatorContext<SourceBase> {
        let context = ListCoordinatorContext(self, setups: setups)
        listContexts.append(.init(context: context))
        return context
    }
    
    // Updates:
    func identifier(for sourceBase: SourceBase) -> AnyHashable {
        let id = ObjectIdentifier(sourceBaseType)
        guard let identifier = differ.identifier else {
            return HashCombiner(id, sectioned)
        }
        return HashCombiner(id, sectioned, identifier(sourceBase))
    }
    
    func equal(lhs: SourceBase, rhs: SourceBase) -> Bool {
        differ.areEquivalent?(lhs, rhs) ?? true
    }
    
    func update(
        from coordinator: ListCoordinator<SourceBase>,
        updateWay: ListUpdateWay<Item>?
    ) -> CoordinatorUpdate {
        fatalError("should be implemented by subclass")
    }
    
    func update(_ update: ListUpdate<SourceBase>) -> CoordinatorUpdate {
        fatalError("should be implemented by subclass")
    }
}
