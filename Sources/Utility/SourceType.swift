//
//  SourceType.swift
//  ListKit
//
//  Created by Frain on 2019/12/16.
//

import Foundation

enum SourceIndices: Equatable {
    case section(index: Int, count: Int)
    case cell(indices: [Int])
    
    var count: Int {
        switch self {
        case let .section(_, count): return count
        case let .cell(cells): return cells.count
        }
    }
}

extension Array where Element == SourceIndices {
    func index(of path: IndexPath) -> Int {
        switch self[path.section] {
        case let .section(offset, _): return offset
        case let .cell(indices: indices): return indices[path.item]
        }
    }
    
    func index(of section: Int) -> Int? {
        guard case let .section(offset, _) = self[section] else { return nil }
        return offset
    }
}
