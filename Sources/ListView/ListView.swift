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
    func perform(update: ListUpdate, animated: Bool, completion: ((ListView, Bool) -> Void)?) {
        for (isLast, batchUpdate) in update.updates {
            let completion: ((Bool) -> Void)? = isLast ? { [weak self] finish in
                self.map { completion?($0, finish) }
                update.complete?()
            } : nil
            perform(update: { perform(batchUpdate) }, animated: animated, completion: completion)
        }
    }
    
    func perform(_ update: BatchUpdate) {
        update.change?()
        
        if !update.section.deletions.isEmpty { deleteSections(update.section.deletions) }
        if !update.section.insertions.isEmpty { insertSections(update.section.insertions) }
        if !update.section.updates.isEmpty { reloadSections(update.section.updates) }
        update.section.moves.forEach { moveSection($0.source, toSection: $0.target) }
        
        
        if !update.item.deletions.isEmpty { deleteItems(at: update.item.deletions) }
        if !update.item.insertions.isEmpty { insertItems(at: update.item.insertions) }
        if !update.item.updates.isEmpty { reloadItems(at: update.item.updates) }
        update.item.moves.forEach { moveItem(at: $0.source, to: $0.target) }
    }
}

private var listDelegateKey: Void?

extension SetuptableListView {
    var listDelegate: ListDelegate {
        Associator.getValue(key: &listDelegateKey, from: self, initialValue: .init(self))
    }
    
    func isCoordinator(_ coordinator: Coordinator) -> Bool {
        if let delegate: ListDelegate = Associator.getValue(key: &listDelegateKey, from: self) {
            return isDelegate(delegate) && delegate.coordinator === coordinator
        }
        return false
    }
}
