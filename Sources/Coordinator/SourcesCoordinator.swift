//
//  SourcesCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/11/28.
//

import Foundation

enum SourcesSubelement<Element> {
    case items(id: Int, () -> [Element])
    case element(Element)
}

final class SourcesContext<Source: DataSource>: ListContext where Source.SourceBase == Source {
    let coordinator: ListCoordinator<Source>
    let isSectiond: Bool
    var offset = 0
    var getContexts: () -> [ListContext] = { fatalError() }
    var getItemSources: () -> (Int, Bool)? = { nil }
    
    var itemSources: (Int, Bool)? { getItemSources() }
    var contextType: ListContextType {
        .superContext(isSectiond ? offset : 0, isSectiond ? 0 : offset, getContexts())
    }
    
    init(_ coordinator: ListCoordinator<Source>, isSectiond: Bool) {
        self.coordinator = coordinator
        self.isSectiond = isSectiond
    }
    
    deinit {
        coordinator.removeContext(listContext: self)
    }
}

final class SourcesCoordinator<SourceBase: DataSource, Source>: ListCoordinator<SourceBase>
where
    SourceBase.SourceBase == SourceBase,
    Source: RangeReplaceableCollection,
    Source.Element: DataSource,
    Source.Element.SourceBase.Item == SourceBase.Item
{
    enum SubsourceType {
        case fromSourceBase((SourceBase.Source) -> Source)
        case values
    }
    
    typealias Subcoordinator = ListCoordinator<Source.Element.SourceBase>
    typealias Related = SourcesContext<Source.Element.SourceBase>
    typealias Subsource = (value: SourcesSubelement<Source.Element>, related: Related)
    
    var subsourceType: SubsourceType
    var subsources = [Subsource]()
    var indices = [Int]()
    var isSectioned = false
    var isAnyType = Item.self == Any.self
    
    lazy var selfSelectorSets = initialSelectorSets()
    lazy var others = SelectorSets()
    
    lazy var keepSectionIfEmpty = options.contains(.keepSectionIfEmpty)
    lazy var preferSection = options.contains(.preferSection)
    
    var subsourcesArray: [Source.Element] {
        var sources = [Source.Element]()
        for element in subsources {
            switch element.value {
            case .items(_, let items): sources += items()
            case .element(let element): sources.append(element)
            }
        }
        return sources
    }
    
    override var multiType: SourceMultipleType { .sources }
    override var isEmpty: Bool { subsources.isEmpty }
    
    func pathAndCoordinator(path: IndexPath) -> (path: IndexPath, coordinator: Subcoordinator) {
        var path = path
        let index = sourceIndex(for: path)
        let context = subsources[index].related
        isSectioned ? (path.section -= context.offset) : (path.item -= context.offset)
        return (path, context.coordinator)
    }
    
    func sourceIndex(for path: IndexPath) -> Int {
        indices[isSectioned ? path.section : path.item]
    }
    
    func setupSelectorSets() {
        others = initialSelectorSets(withoutIndex: true)
        for (_, context) in subsources where context.coordinator.isEmpty == false {
            others.void.formIntersection(context.coordinator.selectorSets.void)
            others.withIndex.formUnion(context.coordinator.selectorSets.withIndex)
            others.withIndexPath.formUnion(context.coordinator.selectorSets.withIndexPath)
            others.hasIndex = others.hasIndex || context.coordinator.selectorSets.hasIndex
        }
        selectorSets = SelectorSets(merging: selfSelectorSets, others)
    }
    
    func subcoordinatorApply<Object: AnyObject, Input, Output>(
        _ keyPath: KeyPath<Coordinator, Delegate<Object, Input, Output>>,
        object: Object,
        with input: Input,
        _ sectionOffset: Int,
        _ itemOffset: Int
    ) -> Output? {
        var (sectionOffset, itemOffset) = (sectionOffset, itemOffset)
        guard let delegateIndex = self[keyPath: keyPath].index else { return nil }
        let index: Int
        switch delegateIndex {
        case let .index(keyPath):
            index = indices[input[keyPath: keyPath] - sectionOffset]
        case let .indexPath(keyPath):
            var indexPath = input[keyPath: keyPath]
            indexPath.item -= itemOffset
            index = sourceIndex(for: indexPath)
        }
        let context = subsources[index].related
        context.isSectiond ? (sectionOffset += context.offset) : (itemOffset += context.offset)
        let coordinator = context.coordinator
        return coordinator.apply(keyPath, object: object, with: input, sectionOffset, itemOffset)
    }
    
    func resetAndConfigIndicesAndOffsets() {
        indices.removeAll(keepingCapacity: true)
        configOffsetAndIndices()
        setupSelectorSets()
    }
    
    func subsources(for source: Source) -> (isSectiond: Bool, values: [Subsource]) {
        var isSectioned = false
        var itemSources = [(element: Source.Element, coordinator: Subcoordinator)]()
        var subsources = [Subsource]()
        var id = 0
        func addItemSources() {
            let coordinator = SourcesCoordinator<Source.Element.SourceBase, [Source.Element]>(
                elements: itemSources,
                defaultUpdate: defaultUpdate
            )
            let context = SourcesContext(coordinator, isSectiond: true)
            subsources.append((.items(id: id) { coordinator.subsourcesArray }, context))
            itemSources.removeAll()
            id += 1
        }
        
        for element in source {
            let coordinator = element.makeListCoordinator()
            coordinator.setupIfNeeded()
            switch coordinator.sourceType {
            case .section:
                if !itemSources.isEmpty { addItemSources() }
                subsources.append((.element(element), .init(coordinator, isSectiond: true)))
                isSectioned = true
            case .cell:
                itemSources.append((element, coordinator))
            }
        }
        
        switch (isSectioned, itemSources.isEmpty) {
        case (true, false):
            addItemSources()
        case (false, false):
            subsources = itemSources.map {
                (.element($0.element), .init($0.coordinator, isSectiond: false))
            }
        default:
            break
        }
        
        return (isSectioned, subsources)
    }
    
    func configOffsetAndIndices() {
        var offset = 0
        var indices = [Int]()
        for (index, (_, context)) in subsources.enumerated() {
            context.offset = offset
            let count = isSectioned
                ? context.coordinator.numbersOfSections()
                : context.coordinator.numbersOfItems(in: 0)
            if count == 0 { continue }
            indices += .init(repeating: index, count: count)
            offset += count
        }
        self.indices = indices
    }
    
    init(
        _ sourceBase: SourceBase,
        storage: CoordinatorStorage<SourceBase>? = nil,
        toSource: @escaping (SourceBase.Source) -> (Source)
    ) {
        let source = sourceBase.source(storage: storage)
        subsourceType = .fromSourceBase(toSource)
        super.init(defaultUpdate: sourceBase.listUpdate, source: source, storage: storage)
    }
    
    init(
        elements: [(element: Source.Element, coordinator: Subcoordinator)],
        defaultUpdate: ListUpdate<SourceBase.Item>
    ) {
        subsourceType = .values
        super.init(defaultUpdate: defaultUpdate, source: nil, storage: nil)
        subsources = elements.map {
            (.element($0.element), .init($0.coordinator, isSectiond: false))
        }
    }
    
    override func item(at path: IndexPath) -> Item {
        let (path, subcoordinator) = pathAndCoordinator(path: path)
        return subcoordinator.item(at: path)
    }
    
    override func itemRelatedCache(at path: IndexPath) -> ItemRelatedCache {
        let (path, subcoordinator) = pathAndCoordinator(path: path)
        return subcoordinator.itemRelatedCache(at: path)
    }
    
    override func numbersOfSections() -> Int {
        isSectioned ? indices.count : isEmpty && !keepSectionIfEmpty ? 0 : 1
    }
    
    override func numbersOfItems(in section: Int) -> Int {
        guard isSectioned else { return indices.count }
        let index = indices[section]
        let context = subsources[index].related
        return context.coordinator.numbersOfItems(in: section - context.offset)
    }
    
    override func setup() {
        if case let .fromSourceBase(closure) = subsourceType {
            (isSectioned, subsources) = subsources(for: closure(source))
        }
        
        configOffsetAndIndices()
        setupSelectorSets()
        sourceType = (isSectioned || selectorSets.hasIndex) ? .section : .cell
    }
    
    override func setupContext(listContext: ListContext) {
        super.setupContext(listContext: listContext)
        
        subsources.forEach {
            let context = $0.related
            context.coordinator.setupContext(listContext: context)
            context.getContexts = { [unowned self] in self.listContexts.values.map { $0.context } }
            if isSectioned { return }
            context.getItemSources = { [unowned self] in
                (self.numbersOfItems(in: 0), self.keepSectionIfEmpty)
            }
        }
    }
    
    override func selectorSets(applying: (inout SelectorSets) -> Void) {
        super.selectorSets(applying: applying)
        applying(&selfSelectorSets)
    }
    
    override func apply<Object: AnyObject, Input, Output>(
        _ keyPath: KeyPath<Coordinator, Delegate<Object, Input, Output>>,
        object: Object,
        with input: Input,
        _ sectionOffset: Int,
        _ itemOffset: Int
    ) -> Output {
        subcoordinatorApply(keyPath, object: object, with: input, sectionOffset, itemOffset)
            ?? super.apply(keyPath, object: object, with: input, sectionOffset, itemOffset)
    }
    
    override func apply<Object: AnyObject, Input>(
        _ keyPath: KeyPath<Coordinator, Delegate<Object, Input, Void>>,
        object: Object,
        with input: Input,
        _ sectionOffset: Int,
        _ itemOffset: Int
    ) {
        subcoordinatorApply(keyPath, object: object, with: input, sectionOffset, itemOffset)
        super.apply(keyPath, object: object, with: input, sectionOffset, itemOffset)
    }
}

extension SourcesCoordinator where SourceBase.Source == Source {
    convenience init(sources sourceBase: SourceBase) {
        self.init(sourceBase, storage: nil) { $0 }
    }
}

extension SourcesCoordinator where SourceBase.Source == Source, SourceBase: UpdatableDataSource {
    convenience init(updatableSources sourceBase: SourceBase) {
        self.init(sourceBase, storage: sourceBase.coordinatorStorage) { $0 }
    }
}
