//
//  Delegate.swift
//  ListKit
//
//  Created by Frain on 2019/12/9.
//

import Foundation

struct Delegate<Object: AnyObject, Input, Output> {
    let selector: Selector
    var closure: ((Object, Input, CoordinatorContext) -> Output)?
    
    init(_ selector: Selector) {
        self.selector = selector
        self.closure = nil
    }
}

struct IndexDelegate<Object: AnyObject, Input, Output, Index: ListIndex> {
    let selector: Selector
    let index: KeyPath<Input, Index>
    let output: (Input, Object) -> Output
    var closure: ((Object, Input, CoordinatorContext, Index) -> Output)?
    
    func output(with input: Input, objct: Object) -> Output {
        output(input, objct)
    }
    
    init(
        _ selector: Selector,
        index: KeyPath<Input, Index>,
        output: @escaping (Input, Object) -> Output
    ) {
        self.selector = selector
        self.index = index
        self.closure = nil
        self.output = output
    }
}

extension IndexDelegate where Output == Void {
    init(_ selector: Selector, index: KeyPath<Input, Index>) {
        self.index = index
        self.selector = selector
        self.output = { _, _ in () }
    }
}
