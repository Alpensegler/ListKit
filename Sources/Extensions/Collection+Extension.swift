//
//  Collection+Extension.swift
//  ListKit
//
//  Created by Frain on 2019/10/15.
//

protocol PathConvertible {
    var section: Int { get }
    var item: Int { get }
    var path: Path { get }
}

struct Path: Hashable, Comparable, PathConvertible {
    var section: Int = 0
    var item: Int = 0
    var path: Path { self }
    
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

func < (lhs: PathConvertible, rhs: PathConvertible) -> Bool { lhs.path < rhs.path }
func - (lhs: PathConvertible, rhs: PathConvertible) -> Path { lhs.path - rhs.path }
func + (lhs: PathConvertible, rhs: PathConvertible) -> Path { lhs.path + rhs.path }

extension RangeReplaceableCollection {
    subscript(safe index: Index) -> Element? {
        guard startIndex <= index, index < endIndex else { return nil }
        return self[index]
    }
}

extension RandomAccessCollection where Element: RandomAccessCollection {
    subscript(path: PathConvertible) -> Element.Element {
        let element = self[index(startIndex, offsetBy: path.section)]
        return element[element.index(element.startIndex, offsetBy: path.item)]
    }
}

#if canImport(Foundation)
import Foundation

extension IndexPath: PathConvertible {
    var path: Path { Path(section: section, item: item) }
}

#endif
