//
//  IndexPath+extension.swift
//  ListKit
//
//  Created by Frain on 2020/5/7.
//

import Foundation

protocol Offsetable {
    func adding(offset: Self) -> Self
}

extension IndexPath {
    static var transform: (IndexPath) -> Int { { $0.item } }
    static var listZero: IndexPath { IndexPath(section: 0, item: 0) }
    
    static func + (lhs: IndexPath, rhs: IndexPath) -> IndexPath {
        guard lhs.count == rhs.count else { fatalError() }
        return .init(indexes: zip(lhs, rhs).map { $0 + $1 })
    }
    
    static func - (lhs: IndexPath, rhs: IndexPath) -> IndexPath {
        guard lhs.count == rhs.count else { fatalError() }
        return .init(indexes: zip(lhs, rhs).map { $0 - $1 })
    }
    
    init(section: Int = 0, item: Int = 0) {
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

extension IndexPath: Offsetable {
    func adding(offset: IndexPath) -> IndexPath {
        adding(section: offset.section, item: offset.item)
    }
}

extension Int: Offsetable {
    func adding(offset: Int) -> Int {
        self + offset
    }
}

extension RandomAccessCollection where Element: RandomAccessCollection {
    subscript(path: IndexPath) -> Element.Element {
        let element = self[index(startIndex, offsetBy: path.section)]
        return element[element.index(element.startIndex, offsetBy: path.item)]
    }
}
