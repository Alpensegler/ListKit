//
//  ListViewDelegate.swift
//  SundayListKit
//
//  Created by Frain on 2019/3/25.
//  Copyright © 2019 Frain. All rights reserved.
//

public protocol TableListDelegate: TableViewDelegate, TableViewDataSource { }
public protocol CollectionListDelegate: CollectionViewDelegateFlowLayout, CollectionViewDataSource { }

fileprivate class AllListViewsWrapper<List: ListView> {
    var datas = [() -> List?]()
}

private var tableListDelegateAllListViewWrapper: Void?

extension TableListDelegate {
    fileprivate var allListViewWrapper: AllListViewsWrapper<UITableView> {
        return Associator.getValue(key: &tableListDelegateAllListViewWrapper, from: self, initialValue: .init())
    }
    
    var allTableViews: LazyMapSequence<LazyFilterSequence<LazyMapSequence<[() -> UITableView?], UITableView?>>, UITableView> {
        return allListViewWrapper.datas.lazy.compactMap { $0() }
    }
}


private var collectionListDelegateAllListViewWrapper: Void?

extension CollectionListDelegate {
    fileprivate var allListViewWrapper: AllListViewsWrapper<UICollectionView> {
        return Associator.getValue(key: &collectionListDelegateAllListViewWrapper, from: self, initialValue: .init())
    }
    
    var allCollectionViews: LazyMapSequence<LazyFilterSequence<LazyMapSequence<[() -> UICollectionView?], UICollectionView?>>, UICollectionView> {
        return allListViewWrapper.datas.lazy.compactMap { $0() }
    }
}

private var tableListDelegateKey: Void?
private var collectionListDelegateKey: Void?

public extension UITableView {
    
    var listDelegate: TableListDelegate? {
        get {
            return Associator.getValue(key: &tableListDelegateKey, from: self)
        }
        set {
            Associator.set(value: newValue, policy: .weak, key: &tableListDelegateKey, to: self)
            newValue?.allListViewWrapper.datas.append { [weak self, weak delegate = newValue] () -> UITableView? in
                guard let self = self, self.listDelegate === delegate else { return nil }
                return self
            }
        }
    }
}

public extension UICollectionView {
    
    var listDelegate: CollectionListDelegate? {
        get {
            return Associator.getValue(key: &collectionListDelegateKey, from: self)
        }
        set {
            Associator.set(value: newValue, policy: .weak, key: &collectionListDelegateKey, to: self)
            newValue?.allListViewWrapper.datas.append { [weak self, weak delegate = newValue] () -> UICollectionView? in
                guard let self = self, self.listDelegate === delegate else { return nil }
                return self
            }
        }
    }
}

