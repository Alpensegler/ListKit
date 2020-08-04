//
//  SourcesCoordinatorContext.swift
//  ListKit
//
//  Created by Frain on 2020/6/8.
//

import Foundation

class SourcesCoordinatorContext<SourceBase: DataSource, Source>: ListCoordinatorContext<SourceBase>
where
    SourceBase.SourceBase == SourceBase,
    Source: RangeReplaceableCollection,
    Source.Element: DataSource,
    Source.Element.SourceBase.Item == SourceBase.Item
{
    lazy var finalSelectorSets = configSelectedSet()
    let sourcesCoordinator: SourcesCoordinator<SourceBase, Source>
    
    var subsources: ContiguousArray<SourcesCoordinator<SourceBase, Source>.Subsource> {
        sourcesCoordinator.subsources
    }
    
    override var selectorSets: SelectorSets { finalSelectorSets }
    
    init(
        _ coordinator: SourcesCoordinator<SourceBase, Source>,
        setups: [(ListCoordinatorContext<SourceBase>) -> Void]
    ) {
        self.sourcesCoordinator = coordinator
        super.init(coordinator, setups: setups)
    }
    
    func configSelectedSet() -> SelectorSets {
        let others = initialSelectorSets(withoutIndex: true)
        for subsource in sourcesCoordinator.subsources {
            others.void.formIntersection(subsource.context.selectorSets.void)
            others.withIndex.formUnion(subsource.context.selectorSets.withIndex)
            others.withIndexPath.formUnion(subsource.context.selectorSets.withIndexPath)
            others.hasIndex = others.hasIndex || subsource.context.selectorSets.hasIndex
        }
        return SelectorSets(merging: selfSelectorSets, others)
    }
    
    func reconfigSelectorSet() {
        finalSelectorSets = configSelectedSet()
        resetDelegates?()
    }
    
    func subcoordinatorApply<Object: AnyObject, Input, Output, Index>(
        _ keyPath: KeyPath<CoordinatorContext, Delegate<Object, Input, Output, Index>>,
        root: CoordinatorContext,
        object: Object,
        with input: Input,
        _ sectionOffset: Int,
        _ itemOffset: Int
    ) -> Output? {
        var (sectionOffset, itemOffset) = (sectionOffset, itemOffset)
        guard let delegateIndex = self[keyPath: keyPath].index else { return nil }
        let index: Int
        switch input[keyPath: delegateIndex] {
        case let section as Int:
            index = sourcesCoordinator.indices[section - sectionOffset].index
        case var indexPath as IndexPath:
            indexPath.item -= itemOffset
            index = sourcesCoordinator.sourceIndex(for: indexPath.section, indexPath.item)
        default:
            fatalError()
        }
        let context = subsources[index], listContext = context.context
        coordinator.sectioned ? (sectionOffset += context.offset) : (itemOffset += context.offset)
        return listContext.apply(keyPath, root: root, object: object, with: input, sectionOffset, itemOffset)
    }
    
    override func apply<Object: AnyObject, Input, Output, Index>(
        _ keyPath: KeyPath<CoordinatorContext, Delegate<Object, Input, Output, Index>>,
        root: CoordinatorContext,
        object: Object,
        with input: Input,
        _ sectionOffset: Int,
        _ itemOffset: Int
    ) -> Output {
        subcoordinatorApply(keyPath, root: root, object: object, with: input, sectionOffset, itemOffset)
            ?? super.apply(keyPath, root: root, object: object, with: input, sectionOffset, itemOffset)
    }
    
    override func apply<Object: AnyObject, Input, Index>(
        _ keyPath: KeyPath<CoordinatorContext, Delegate<Object, Input, Void, Index>>,
        root: CoordinatorContext,
        object: Object,
        with input: Input,
        _ sectionOffset: Int,
        _ itemOffset: Int
    ) {
        subcoordinatorApply(keyPath, root: root, object: object, with: input, sectionOffset, itemOffset)
        super.apply(keyPath, root: root, object: object, with: input, sectionOffset, itemOffset)
    }
}
