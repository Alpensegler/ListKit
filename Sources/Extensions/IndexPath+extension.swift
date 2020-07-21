//
//  IndexPath+extension.swift
//  ListKit
//
//  Created by Frain on 2020/5/7.
//

import Foundation

extension IndexPath {
    static var zero: IndexPath { IndexPath(section: 0, item: 0) }
    
    init(section: Int = 0, item: Int = 0) {
        self = [section, item]
    }
    
    var section: Int {
        get { self[startIndex] }
        set { self[startIndex] = newValue }
    }
    
    var item: Int {
        get { self[index(before: endIndex)] }
        set { self[index(before: endIndex)] = newValue }
    }
    
    func offseted(_ sectionOffset: Int, _ itemOffset: Int) -> IndexPath {
        IndexPath(section: sectionOffset + section, item: itemOffset + itemOffset)
    }
}
