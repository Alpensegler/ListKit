//
//  Extensions.swift
//  SundayListKit
//
//  Created by Frain on 2019/4/7.
//  Copyright © 2019 Frain. All rights reserved.
//

extension Collection where Element: Collection, Self.Index == Int, Self.Element.Index == Int {
    subscript(indexPath: IndexPath) -> Element.Element {
        return self[indexPath.section][indexPath.row]
    }
}

extension IndexPath {
    func addingOffset(_ offset: IndexPath) -> IndexPath {
        return IndexPath(item: offset.item + offset.item, section: offset.section + section)
    }
}
