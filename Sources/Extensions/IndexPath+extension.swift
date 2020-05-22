//
//  IndexPath+extension.swift
//  ListKit
//
//  Created by Frain on 2020/5/7.
//

import Foundation

extension IndexPath {
    static var listZero: IndexPath { IndexPath(section: 0, item: 0) }
    
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
}

extension RandomAccessCollection where Element: RandomAccessCollection {
    subscript(path: IndexPath) -> Element.Element {
        let element = self[index(startIndex, offsetBy: path.section)]
        return element[element.index(element.startIndex, offsetBy: path.item)]
    }
}
