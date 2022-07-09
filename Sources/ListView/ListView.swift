//
//  ListView.swift
//  ListKit
//
//  Created by Frain on 2019/12/5.
//

import Foundation

public protocol ListView: NSObject {
    func resetDelegates(toNil: Bool)
    func reloadSynchronously(animated: Bool)
    func perform(_ update: () -> Void, animated: Bool, completion: ((Bool) -> Void)?)

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
    func setup(with listDelegate: Delegate)
    func isDelegate(_ listDelegate: Delegate) -> Bool
}

private var listDelegateKey: Void?

extension SetuptableListView {
    var listDelegate: Delegate {
        Associator.getValue(key: &listDelegateKey, from: self, initialValue: .init(self))
    }

    func isCoordinator(_ coordinator: AnyObject) -> Bool {
        if let delegate: Delegate = Associator.getValue(key: &listDelegateKey, from: self) {
            return isDelegate(delegate) && delegate.context?.isCoordinator(coordinator) ?? false
        }
        return false
    }
}
