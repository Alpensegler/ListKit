//
//  Extensions.swift
//  SundayListKit
//
//  Created by Frain on 2019/4/7.
//  Copyright © 2019 Frain. All rights reserved.
//

extension Collection
where
    Element: Collection,
    Self.Index == Int,
    Self.Element.Index == Int
{
    subscript(indexPath: IndexPath) -> Element.Element {
        return self[indexPath.section][indexPath.row]
    }
    
    subscript(safe indexPath: IndexPath) -> Element.Element? {
        return self[safe: indexPath.section]?[safe: indexPath.row]
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        guard startIndex <= index, index < endIndex else { return nil }
        return self[index]
    }
}

extension IndexPath {
    static var `default`: IndexPath {
        return IndexPath(item: 0, section: 0)
    }
    
    func addingOffset(_ offset: IndexPath) -> IndexPath {
        return IndexPath(item: offset.item + offset.item, section: offset.section + section)
    }
    
    init(item: Int) {
        self.init(item: item, section: 0)
    }
    
    init(section: Int) {
        self.init(item: 0, section: section)
    }
}
