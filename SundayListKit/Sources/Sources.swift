//
//  Sources.swift
//  SundayListKit
//
//  Created by Frain on 2019/6/4.
//  Copyright © 2019 Frain. All rights reserved.
//

public struct Sources<SubSource, Item, SourceSnapshot: SnapshotType, UIViewType> {
    public internal(set) var listUpdater = ListUpdater()
    public var source: SubSource {
        get { return sourceClosure?() ?? sourceStored }
        set {
            if sourceClosure != nil { return }
            sourceStored = newValue
        }
    }
    
    let sourceClosure: (() -> SubSource)!
    var sourceStored: SubSource! {
        didSet { performUpdate() }
    }
    
    var diffable = AnyDiffable()
    
    //MARK: - Source
    var createSnapshotWith: ((SubSource) -> SourceSnapshot)!
    var itemFor: ((SourceSnapshot, IndexPath) -> Item)!
    var updateContext: ((UpdateContext<SourceSnapshot>) -> Void)!
    
    //MARK: - collection adapter
    var collectionView: (() -> UICollectionView)? = nil
    
    var collectionCellForItem: ((CollectionContext<SourceSnapshot>, Item) -> UICollectionViewCell)! = nil
    var collectionSupplementaryView: ((CollectionContext<SourceSnapshot>, SupplementaryViewType, Item) -> UICollectionReusableView?)? = nil
    
    var collectionDidSelectItem: ((CollectionContext<SourceSnapshot>, Item) -> Void)? = nil
    var collectionWillDisplayItem: ((CollectionContext<SourceSnapshot>, UICollectionViewCell, Item) -> Void)? = nil
    
    var collectionSizeForItem: ((CollectionContext<SourceSnapshot>, UICollectionViewLayout, Item) -> CGSize)? = nil
    var collectionSizeForHeader: ((CollectionContext<SourceSnapshot>, UICollectionViewLayout, Int) -> CGSize)? = nil
    var collectionSizeForFooter: ((CollectionContext<SourceSnapshot>, UICollectionViewLayout, Int) -> CGSize)? = nil
    
    //MARK: - table adapter
    var tableCellForItem: ((TableContext<SourceSnapshot>, Item) -> UITableViewCell)! = nil
    var tableHeader: ((TableContext<SourceSnapshot>, Int) -> UIView?)? = nil
    var tableFooter: ((TableContext<SourceSnapshot>, Int) -> UIView?)? = nil
    
    var tableDidSelectItem: ((TableContext<SourceSnapshot>, Item) -> Void)? = nil
    var tableWillDisplayItem: ((TableContext<SourceSnapshot>, UITableViewCell, Item) -> Void)? = nil
    
    var tableHeightForItem: ((TableContext<SourceSnapshot>, Item) -> CGFloat)? = nil
    var tableHeightForHeader: ((TableContext<SourceSnapshot>, Int) -> CGFloat)? = nil
    var tableHeightForFooter: ((TableContext<SourceSnapshot>, Int) -> CGFloat)? = nil
}

struct AnyDiffable: Identifiable, Equatable {
    static func == (lhs: AnyDiffable, rhs: AnyDiffable) -> Bool {
        guard let l = lhs.base, let r = rhs.base else { return false }
        return l.isContentEqual(to: r)
    }
    
    let _id: () -> AnyHashable
    let _base: (() -> AnyEquatableBox)?
    
    var id: AnyHashable { return _id() }
    var base: AnyEquatableBox? { return _base?() }
    
    init() {
        let uuid = UUID()
        _id = { uuid }
        _base = nil
    }
    
    init(_ id: AnyHashable) {
        _id = { id }
        _base = nil
    }
    
    init<T: Identifiable>(_ identifiable: @escaping () -> T) {
        self._id = { identifiable().id }
        self._base = { EquatableBox(identifiable().id) }
    }
    
    init<T: Identifiable & Equatable>(_ identifiable: @escaping () -> T) {
        self._id = { identifiable().id }
        self._base = { EquatableBox(identifiable()) }
    }
}

protocol AnyEquatableBox {
    var base: Any { get }
    
    func isContentEqual(to source: AnyEquatableBox) -> Bool
}

struct EquatableBox<Base: Equatable>: AnyEquatableBox {
    private let baseComponent: Base
    
    var base: Any {
        return baseComponent
    }
    
    init(_ base: Base) {
        baseComponent = base
    }
    
    func isContentEqual(to source: AnyEquatableBox) -> Bool {
        guard let sourceBase = source.base as? Base else {
            return false
        }
        return baseComponent == sourceBase
    }
}


#if iOS13
import SwiftUI
extension Sources: View where UIViewType: ListView {
    public typealias Body = Never
    public typealias Coordinator = UIViewType.Coordinator
    public var body: Body { fatalError() }
}

extension Sources: UIViewRepresentable where UIViewType: ListView {
    public func makeCoordinator() -> UIViewType.Coordinator {
        fatalError()
    }
    
    public func makeUIView(context: UIViewRepresentableContext<Self>) -> UIViewType {
        fatalError()
    }
    
    public func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<Self>) {
        fatalError()
    }
}

#endif
