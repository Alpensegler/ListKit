//
//  Mapping.swift
//  ListKit
//
//  Created by Frain on 2020/5/18.
//

typealias Mapping<T> = (source: T, target: T)

func path<T>(_ isSouce: Bool) -> WritableKeyPath<Mapping<T>, T> {
    isSouce ? \.source : \.target
}
