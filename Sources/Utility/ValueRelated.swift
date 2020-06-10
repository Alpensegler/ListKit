//
//  ValueRelated.swift
//  ListKit
//
//  Created by Frain on 2020/5/4.
//

final class ValueRelated<Value, Related> {
    let relatedGetter: () -> Related
    let value: Value
    
    lazy var related = relatedGetter()

    init(_ value: Value, related: @autoclosure @escaping () -> Related) {
        self.value = value
        self.relatedGetter = related
    }
}
