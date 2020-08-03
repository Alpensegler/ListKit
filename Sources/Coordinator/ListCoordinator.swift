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

    enum SourceMultipleType {
        case single, multiple, sources, other
    }
    
    let update: ListUpdate<SourceBase>.Whole
    let options: ListOptions<SourceBase>
    var source: SourceBase.Source!
    
    weak var storage: CoordinatorStorage<SourceBase>?
    weak var currentCoordinatorUpdate: ListCoordinatorUpdate<SourceBase>?
    var listContexts = [WeakContext]()
    
    lazy var sectioned = isSectioned()
    
    var isEmpty: Bool { false }
    var sourceBaseType: Any.Type { SourceBase.self }
    var multiType: SourceMultipleType { fatalError() }
    
    init(
        source: SourceBase.Source!,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions<SourceBase> = .init()
    ) {
        self.update = update
        self.options = options
        self.source = source
    }
    
    init(_ sourceBase: SourceBase) {
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
        guard let identifier = options.differ?.identifier else {
            return HashCombiner(id, sectioned, multiType)
        }
        return HashCombiner(id, sectioned, multiType, identifier(sourceBase))
    }
    
    func equal(lhs: SourceBase, rhs: SourceBase) -> Bool {
        options.differ?.areEquivalent?(lhs, rhs) ?? true
    }
    
    func update(
        from coordinator: ListCoordinator<SourceBase>,
        differ: Differ<Item>?
    ) -> ListCoordinatorUpdate<SourceBase> {
        fatalError("should be implemented by subclass")
    }
    
    func update(_ update: ListUpdate<SourceBase>) -> ListCoordinatorUpdate<SourceBase> {
        fatalError("should be implemented by subclass")
    }
}
