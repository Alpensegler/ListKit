//
//  SourcesDelegates.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

class SourcesDelegates<SourceBase: DataSource>: WrapperDelegates<SourceBase>
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: DataSource,
    SourceBase.Source.Element.SourceBase.Item == SourceBase.Item
{
    var subdelegates = [(delegate: Delegates, isEmpty: Bool)]()
    var _others = SelectorSets()
    override var others: SelectorSets { _others }
    
    func configSubdelegatesOffsets() {
        for ((delegates, _), offset) in zip(subdelegates, coordinator.offsets) {
            delegates.sectionOffset = offset.section + sectionOffset
            delegates.itemOffset = offset.item + itemOffset
        }
    }
    
    override func setupSelectorSets() {
        _others = initialSelectorSets(withoutIndex: true)
        for (delegates, isEmpty) in subdelegates where isEmpty == false {
            others.void.formIntersection(delegates.selectorSets.void)
            others.withIndex.formUnion(delegates.selectorSets.withIndex)
            others.withIndexPath.formUnion(delegates.selectorSets.withIndexPath)
            others.hasIndex = others.hasIndex || delegates.selectorSets.hasIndex
        }
        super.setupSelectorSets()
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
