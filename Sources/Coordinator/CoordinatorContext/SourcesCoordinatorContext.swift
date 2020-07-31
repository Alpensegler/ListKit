//
//  SourcesCoordinatorContext.swift
//  ListKit
//
//  Created by Frain on 2020/6/8.
//

class SourcesCoordinatorContext<SourceBase: DataSource, Source>: ListCoordinatorContext<SourceBase>
where
    SourceBase.SourceBase == SourceBase,
    Source: RangeReplaceableCollection,
    Source.Element: DataSource,
    Source.Element.SourceBase.Item == SourceBase.Item
{
    let sourcesCoordinator: SourcesCoordinator<SourceBase, Source>
    
    var subsources: ContiguousArray<SourcesCoordinator<SourceBase, Source>.Subsource> {
        sourcesCoordinator.subsources
    }
    
    init(
        _ coordinator: SourcesCoordinator<SourceBase, Source>,
        setups: [(ListCoordinatorContext<SourceBase>) -> Void]
    ) {
        self.sourcesCoordinator = coordinator
        super.init(coordinator, setups: setups)
        let others = initialSelectorSets(withoutIndex: true)
        for subsource in sourcesCoordinator.subsources {
            others.void.formIntersection(subsource.context.selectorSets.void)
            others.withIndex.formUnion(subsource.context.selectorSets.withIndex)
            others.withIndexPath.formUnion(subsource.context.selectorSets.withIndexPath)
            others.hasIndex = others.hasIndex || subsource.context.selectorSets.hasIndex
        }
        selectorSets = SelectorSets(merging: selectorSets, others)
    }
    
    func subcoordinatorApply<Object: AnyObject, Input, Output>(
        _ keyPath: KeyPath<CoordinatorContext, Delegate<Object, Input, Output>>,
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
            index = sourcesCoordinator.indices[input[keyPath: keyPath] - sectionOffset].index
        case let .indexPath(keyPath):
            var indexPath = input[keyPath: keyPath]
            indexPath.item -= itemOffset
            index = sourcesCoordinator.sourceIndex(for: indexPath.section, indexPath.item)
        }
        let context = subsources[index], listContext = context.context
        coordinator.sectioned ? (sectionOffset += context.offset) : (itemOffset += context.offset)
        return listContext.apply(keyPath, object: object, with: input, sectionOffset, itemOffset)
    }
    
    override func apply<Object: AnyObject, Input, Output>(
        _ keyPath: KeyPath<CoordinatorContext, Delegate<Object, Input, Output>>,
        object: Object,
        with input: Input,
        _ sectionOffset: Int,
        _ itemOffset: Int
    ) -> Output {
        subcoordinatorApply(keyPath, object: object, with: input, sectionOffset, itemOffset)
            ?? super.apply(keyPath, object: object, with: input, sectionOffset, itemOffset)
    }
    
    override func apply<Object: AnyObject, Input>(
        _ keyPath: KeyPath<CoordinatorContext, Delegate<Object, Input, Void>>,
        object: Object,
        with input: Input,
        _ sectionOffset: Int,
        _ itemOffset: Int
    ) {
        subcoordinatorApply(keyPath, object: object, with: input, sectionOffset, itemOffset)
        super.apply(keyPath, object: object, with: input, sectionOffset, itemOffset)
    }
}
