//
//  Collection+Extension.swift
//  ListKit
//
//  Created by Frain on 2019/10/15.
//

import Foundation

extension Collection {
    var nonNilFirst: Element { self[startIndex] }
}

extension MutableCollection {
    var nonNilFirst: Element {
        get { self[startIndex] }
        set { self[startIndex] = newValue }
    }
}

extension BidirectionalCollection {
    var nonNilLast: Element { self[index(before: endIndex)] }
}

extension BidirectionalCollection where Self: MutableCollection {
    var nonNilLast: Element {
        get { self[index(before: endIndex)] }
        set { self[index(before: endIndex)] = newValue }
    }
}

extension RangeReplaceableCollection {
    subscript(safe index: Index) -> Element? {
        guard startIndex <= index, index < endIndex else { return nil }
        return self[index]
    }
}

extension RandomAccessCollection where Element: RandomAccessCollection {
    subscript(path: IndexPath) -> Element.Element {
        let element = self[index(startIndex, offsetBy: path[0])]
        return element[element.index(element.startIndex, offsetBy: path[1])]
    }
}
