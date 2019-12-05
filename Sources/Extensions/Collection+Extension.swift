//
//  Collection+Extension.swift
//  ListKit
//
//  Created by Frain on 2019/10/15.
//

struct Path: Hashable, Comparable {
    var section: Int = 0
    var item: Int = 0
    
    static func < (lhs: Path, rhs: Path) -> Bool {
        lhs.section < rhs.section || (lhs.section == rhs.section && lhs.item < rhs.item)
    }

    static func - (lhs: Path, rhs: Path) -> Path {
        Path(section: lhs.section - rhs.section, item: lhs.item - rhs.item)
    }

    static func + (lhs: Path, rhs: Path) -> Path {
        Path(section: lhs.section + rhs.section, item: lhs.item + rhs.item)
    }
}

extension RangeReplaceableCollection {
    subscript(safe index: Index) -> Element? {
        guard startIndex <= index, index < endIndex else { return nil }
        return self[index]
    }
}

extension RandomAccessCollection where Element: RandomAccessCollection {
    subscript(path: Path) -> Element.Element {
        let element = self[index(startIndex, offsetBy: path.section)]
        return element[element.index(element.startIndex, offsetBy: path.item)]
    }
}

