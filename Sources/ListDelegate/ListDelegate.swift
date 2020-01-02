//
//  ListDelegate.swift
//  ListKit
//
//  Created by Frain on 2020/1/1.
//

import Foundation

final class ListDelegate: NSObject {
    var coordinator: BaseCoordinator
    
    init(coordinator: BaseCoordinator) {
        self.coordinator = coordinator
    }
    
    func apply<Object: AnyObject, Input, Output>(
        _ keyPath: KeyPath<BaseCoordinator, Delegate<Object, Input, Output>>,
        object: Object,
        with input: Input
    ) -> Output {
        coordinator.apply(keyPath, object: object, with: input)
    }
    
    func apply<Object: AnyObject, Input>(
        _ keyPath: KeyPath<BaseCoordinator, Delegate<Object, Input, Void>>,
        object: Object,
        with input: Input
    ) {
        coordinator.apply(keyPath, object: object, with: input)
    }
    
    func apply<Object: AnyObject, Output>(
        _ keyPath: KeyPath<BaseCoordinator, Delegate<Object, Void, Output>>,
        object: Object
    ) -> Output {
        apply(keyPath, object: object, with: ())
    }
    
    func apply<Object: AnyObject>(
        _ keyPath: KeyPath<BaseCoordinator, Delegate<Object, Void, Void>>,
        object: Object
    ) {
        apply(keyPath, object: object, with: ())
    }
}
