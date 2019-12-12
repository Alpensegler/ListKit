//
//  ListAdapter.swift
//  ListKit
//
//  Created by Frain on 2019/12/5.
//

public protocol ListAdapter: DataSource { }

extension ListAdapter {
    func set<Object: AnyObject, Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<BaseCoordinator, Delegate<Object, Input, Output>>,
        _ closure: @escaping ((Object, Input)) -> Output
    ) -> Self {
        listCoordinator.set(keyPath, closure)
        return self
    }

    func set<Object: AnyObject, Input>(
        _ keyPath: ReferenceWritableKeyPath<BaseCoordinator, Delegate<Object, Input, Void>>,
        _ closure: @escaping ((Object, Input)) -> Void
    ) -> Self {
        listCoordinator.set(keyPath, closure)
        return self
    }
}
