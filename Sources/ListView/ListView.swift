//
//  ListView.swift
//  ListKit
//
//  Created by Frain on 2019/12/5.
//

import Foundation

public protocol ListView: NSObject {
    func reloadSynchronously(animated: Bool)
    func perform(update: () -> Void, animated: Bool, completion: ((Bool) -> Void)?)
    
    func insertItems(at indexPaths: [IndexPath])
    func deleteItems(at indexPaths: [IndexPath])
    func reloadItems(at indexPaths: [IndexPath])
    func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath)
    func insertSections(_ sections: IndexSet)
    func deleteSections(_ sections: IndexSet)
    func reloadSections(_ sections: IndexSet)
    func moveSection(_ section: Int, toSection newSection: Int)
}

protocol SetuptableListView: ListView {
    func setup(with listDelegate: ListDelegate)
    func isDelegate(_ listDelegate: ListDelegate) -> Bool
}

extension ListView {
    func perform(updates: BatchUpdates, animated: Bool, completion: ((ListView, Bool) -> Void)?) {
        switch updates {
        case let .reload(change: change):
            change?()
            reloadSynchronously(animated: animated)
            completion?(self, true)
        case let .batch(batchUpdates):
            for (offset, batchUpdate) in batchUpdates.enumerated() {
                Log.log("------------------------------")
                Log.log(batchUpdate.listDebugDescription)
                let isLast = offset == batchUpdates.count - 1
                let completion: ((Bool) -> Void)? = isLast ? { [weak self] finish in
                    self.map { completion?($0, finish) }
                } : nil
                perform(update: {
                    batchUpdate.change?()
                    batchUpdate.update.source?.apply(by: self)
                    batchUpdate.update.target?.apply(by: self)
                }, animated: animated, completion: completion)
            }
        }
    }
}

private var listDelegateKey: Void?

extension SetuptableListView {
    var listDelegate: ListDelegate {
        Associator.getValue(key: &listDelegateKey, from: self, initialValue: .init(self))
    }
    
    func isCoordinator<SourceBase>(_ coordinator: ListCoordinator<SourceBase>) -> Bool {
        if let delegate: ListDelegate = Associator.getValue(key: &listDelegateKey, from: self) {
            return isDelegate(delegate) && delegate.context?.isCoordinator(coordinator) ?? false
        }
        return false
    }
}
