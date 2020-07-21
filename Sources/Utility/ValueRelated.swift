//
//  ValueRelated.swift
//  ListKit
//
//  Created by Frain on 2020/5/4.
//

struct ValueRelated<Value, Related> {
    let value: Value
    var related: Related

    init(_ value: Value, related: Related) {
        self.value = value
        self.related = related
    }
}
