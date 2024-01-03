//
//  ChangeSet.swift
//  ListKit
//
//  Created by Frain on 2020/9/2.
//

import Foundation

//struct ChangeSets<Set: UpdateIndexCollection> {
//    typealias Index = Set.Element
//    typealias Indices = Set.Elements
//
//    var source = BatchUpdates.Source<Set>()
//    var target = BatchUpdates.Target<Set>()
//    var reloadDict = [Index: Index]()
//}
//
//extension ChangeSets {
//    mutating func insert(_ index: Index) {
//        target.add(\.inserts, index)
//    }
//
//    mutating func insert(_ indices: Indices) {
//        target.add(\.inserts, indices)
//    }
//
//    mutating func delete(_ index: Index) {
//        source.add(\.deletes, index)
//    }
//
//    mutating func delete(_ indices: Indices) {
//        source.add(\.deletes, indices)
//    }
//
//    mutating func reload(_ index: Index, newIndex: Index) {
//        source.add(\.reloads, index)
//        target.add(\.reloads, newIndex)
//        reloadDict[index] = newIndex
//    }
//
//    mutating func reload(_ indices: Indices, newIndices: Indices) {
//        source.add(\.reloads, indices)
//        target.add(\.reloads, newIndices)
//        zip(indices, newIndices).forEach { reloadDict[$0.0] = $0.1 }
//    }
//
//    mutating func move(_ index: Index, to newIndex: Index) {
//        source.move(index)
//        target.move(index, to: newIndex)
//        target.moveDict[newIndex] = index
//    }
//}
