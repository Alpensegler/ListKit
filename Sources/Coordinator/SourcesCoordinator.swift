//
//  SourcesCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/11/28.
//

import Foundation

enum SourcesSubelement<Element> {
    case items(() -> [Element])
    case element(Element)
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
        case values(Int)
    }
    
    typealias Subcoordinator = ListCoordinator<Source.Element.SourceBase>
    typealias Subsource = (value: SourcesSubelement<Source.Element>, related: Subcoordinator)
    
    var subsourceType: SubsourceType
    var subsources = [Subsource]()
    var offsets = [Int]()
    var indices = [Int]()
    var isSectioned = false
    var isAnyType = Item.self == Any.self
    
    lazy var selfSelectorSets = initialSelectorSets()
    lazy var others = SelectorSets()
    
    var subsourcesArray: [Source.Element] {
        var sources = [Source.Element]()
        for element in subsources {
            switch element.value {
            case .items(let items): sources += items()
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
        let offset = offsets[index]
        isSectioned ? (path.section -= offset) : (path.item -= offset)
        return (path, subsources[index].related)
    }
    
    func sourceIndex(for path: IndexPath) -> Int {
        indices[isSectioned ? path.section : path.item]
    }
    
    func setupSelectorSets() {
        others = initialSelectorSets(withoutIndex: true)
        for (_, coordinator) in subsources where coordinator.isEmpty == false {
            others.void.formIntersection(coordinator.selectorSets.void)
            others.withIndex.formUnion(coordinator.selectorSets.withIndex)
            others.withIndexPath.formUnion(coordinator.selectorSets.withIndexPath)
            others.hasIndex = others.hasIndex || coordinator.selectorSets.hasIndex
        }
        selectorSets = SelectorSets(merging: selfSelectorSets, others)
    }
    
    func subcoordinator<Object: AnyObject, Input, Output>(
        for delegate: Delegate<Object, Input, Output>,
        object: Object,
        with input: Input
    ) -> Coordinator? {
        guard let index = delegate.index else { return nil }
        let (sectionOffset, itemOffset) = offset(for: object)
        let offset: Int
        switch index {
        case let .index(keyPath):
            offset = indices[input[keyPath: keyPath] - sectionOffset]
        case let .indexPath(keyPath):
            var indexPath = input[keyPath: keyPath]
            indexPath.item -= itemOffset
            offset = self.sourceIndex(for: indexPath)
        }
        let coordinator = subsources[offset].related
        return coordinator.selectorSets.contains(delegate.selector) ? nil : coordinator
    }
    
    func resetAndConfigIndicesAndOffsets() {
        offsets.removeAll(keepingCapacity: true)
        indices.removeAll(keepingCapacity: true)
        setup()
        configSubcoordinator(for: listContexts)
        setupSelectorSets()
    }
    
    func configSubcoordinator(for contexts: [ObjectIdentifier: ListContext]) {
        for (key, value) in contexts {
            guard let listView = value.listView else { continue }
            for ((_, subcoordinator), offset) in zip(subsources, offsets) {
                subcoordinator.setupContext(
                    listView: listView,
                    key: key,
                    sectionOffset: isSectioned ? offset + value.sectionOffset : 0,
                    itemOffset: isSectioned ? 0 : offset + value.itemOffset,
                    supercoordinator: self
                )
            }
        }
    }
    
    func subsources(for source: Source) -> (isSectiond: Bool, values: [Subsource]) {
        var isSectioned = false
        var itemSources = [(element: Source.Element, coordinator: Subcoordinator)]()
        var subsources = [Subsource]()
        var id = 0
        func addItemSources() {
            let coordinator = SourcesCoordinator<Source.Element.SourceBase, [Source.Element]>(
                elements: itemSources,
                defaultUpdate: defaultUpdate,
                id: id
            )
            subsources.append((.items { coordinator.subsourcesArray }, coordinator))
            itemSources.removeAll()
            id += 1
        }
        
        for element in source {
            let coordinator = element.makeListCoordinator()
            coordinator.setupIfNeeded()
            switch coordinator.sourceType {
            case .section:
                if !itemSources.isEmpty { addItemSources() }
                subsources.append((.element(element), coordinator))
                isSectioned = true
            case .cell:
                itemSources.append((element, coordinator))
            }
        }
        
        switch (isSectioned, itemSources.isEmpty) {
        case (true, false): addItemSources()
        case (false, false): subsources = itemSources.map { (.element($0.element), $0.coordinator) }
        default: break
        }
        
        return (isSectioned, subsources)
    }
    
    func configOffsetAndIndices() {
        var offset = 0
        var indices = [Int]()
        for (index, (_, coordinator)) in subsources.enumerated() {
            offsets.append(offset)
            let count = isSectioned
                ? coordinator.numbersOfSections()
                : coordinator.numbersOfItems(in: 0)
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
        defaultUpdate: ListUpdate<SourceBase.Item>,
        id: Int
    ) {
        subsourceType = .values(id)
        super.init(defaultUpdate: defaultUpdate, source: nil, storage: nil)
        subsources = elements.map { (.element($0.element), $0.coordinator) }
    }
    
    override func item(at path: IndexPath) -> Item {
        let (path, subcoordinator) = pathAndCoordinator(path: path)
        return subcoordinator.item(at: path)
    }
    
    override func itemRelatedCache(at path: IndexPath) -> ItemRelatedCache {
        let (path, subcoordinator) = pathAndCoordinator(path: path)
        return subcoordinator.itemRelatedCache(at: path)
    }
    
    override func numbersOfSections() -> Int { isSectioned ? indices.count : 1 }
    override func numbersOfItems(in section: Int) -> Int {
        guard isSectioned else { return indices.count }
        let index = indices[section]
        let offset = offsets[index]
        return subsources[index].related.numbersOfItems(in: section - offset)
    }
    
    override func setup() {
        if case let .fromSourceBase(closure) = subsourceType {
            (isSectioned, subsources) = subsources(for: closure(source))
        }
        
        configOffsetAndIndices()
        setupSelectorSets()
        sourceType = (isSectioned || selectorSets.hasIndex) ? .section : .cell
    }
    
    override func setupContext(
        listView: ListView,
        key: ObjectIdentifier,
        sectionOffset: Int = 0,
        itemOffset: Int = 0,
        supercoordinator: Coordinator? = nil
    ) {
        if let context = listContexts[key] {
            context.sectionOffset = sectionOffset
            context.itemOffset = itemOffset
            configSubcoordinator(for: [key: context])
            return
        }
        
        let context = ListContext(
            listView: listView,
            sectionOffset: sectionOffset,
            itemOffset: itemOffset,
            supercoordinator: supercoordinator
        )
        listContexts[key] = context
        configSubcoordinator(for: [key: context])
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
