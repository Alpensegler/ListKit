//
//  NestedAdapter.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

import Foundation

public extension ListIndexContext where Index == IndexPath {
    @discardableResult
    func nestedAdapter<Adapter: ListAdapter>(
        _ keyPath: KeyPath<Base.Model, Adapter>,
        applyBy view: Adapter.View,
        animated: Bool = true,
        completion: ((Bool) -> Void)? = nil
    ) -> ListAdaptation<Adapter.AdapterBase, Adapter.View> {
        let adapter = model[keyPath: keyPath]
        let list = adapter.apply(
            by: view,
            update: .reload,
            animated: animated,
            completion: completion
        )
        var coordinator = list.listCoordinator
        setNestedCache { [weak view] base in
            guard let baseModel = base as? Base.Model,
                  let view = view,
                  (view as? DelegateSetuptable)?.isCoordinator(coordinator) == true
            else { return }
            let adapter = baseModel[keyPath: keyPath]
            let list = adapter.apply(by: view, animated: animated, completion: completion)
            coordinator = list.listCoordinator
        }
        return list
    }
}

public extension ListIndexContext where Index == IndexPath, Base.Model: ListAdapter {
    @discardableResult
    func nestedAdapter(applyBy view: Base.Model.View) -> ListAdaptation<Base.Model.AdapterBase, Base.Model.View> {
        nestedAdapter(\.self, applyBy: view)
    }
}
