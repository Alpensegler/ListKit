//
//  IndexPath+extension.swift
//  ListKit
//
//  Created by Frain on 2020/5/7.
//

import Foundation

typealias Path = IndexPath

extension Path {
    static var transform: (Path) -> Int { { $0.item } }
    
    static func + (lhs: Path, rhs: Path) -> IndexPath {
        guard lhs.count == rhs.count else { fatalError() }
        return .init(indexes: zip(lhs, rhs).map { $0 + $1 })
    }
    
    static func - (lhs: Path, rhs: Path) -> IndexPath {
        guard lhs.count == rhs.count else { fatalError() }
        return .init(indexes: zip(lhs, rhs).map { $0 - $1 })
    }
    
    init(section: Int, item: Int = 0) {
        self = [section, item]
    }
    
    var section: Int {
        get { nonNilFirst }
        set { nonNilFirst = newValue }
    }
    
    var item: Int {
        get { nonNilLast }
        set { nonNilLast = newValue }
    }
    
    func adding(section: Int = 0, item: Int) -> IndexPath {
        var path = self
        path.section += section
        path.item += item
        return path
    }
}
