//
//  IdentifiableExtensions.swift
//  SundayListKit
//
//  Created by Frain on 2019/6/5.
//  Copyright © 2019 Frain. All rights reserved.
//

#if iOS13
import SwiftUI
#endif

public extension Collection where Element: Identifiable {
    func firstIndex(of element: Self.Element) -> Self.Index? {
        return firstIndex(where: { $0.id == element.id })
    }
}

public extension Collection where Element: Identifiable, Element: Equatable {
    func firstIndex(of element: Self.Element) -> Self.Index? {
        return firstIndex(where: { $0.id == element.id })
    }
}

extension RangeReplaceableCollection where Element: Identifiable {
    mutating func insert(elements: [Element], after element: Element) {
        _insert(elements: elements, after: element, by: firstIndex(of:))
    }
    
    mutating func insert(elements: [Element], before element: Element) {
        _insert(elements: elements, before: element, by: firstIndex(of:))
    }
}

extension RangeReplaceableCollection where Element: Equatable {
    mutating func insert(elements: [Element], after element: Element) {
        _insert(elements: elements, after: element, by: firstIndex(of:))
    }
    
    mutating func insert(elements: [Element], before element: Element) {
        _insert(elements: elements, before: element, by: firstIndex(of:))
    }
}

extension RangeReplaceableCollection where Element: Equatable, Element: Identifiable {
    mutating func insert(elements: [Element], after element: Element) {
        _insert(elements: elements, after: element, by: firstIndex(of:))
    }
    
    mutating func insert(elements: [Element], before element: Element) {
        _insert(elements: elements, before: element, by: firstIndex(of:))
    }
}

extension RangeReplaceableCollection where Self: RandomAccessCollection, Element: Equatable {
    
    mutating func move(elements: [Element], after element: Element) {
        _move(elements: elements, after: element, by: firstIndex(of:))
    }
    
    mutating func move(elements: [Element], before element: Element) {
        _move(elements: elements, before: element, by: firstIndex(of:))
    }
}

extension RangeReplaceableCollection where Self: RandomAccessCollection, Element: Identifiable {
    
    mutating func move(elements: [Element], after element: Element) {
        _move(elements: elements, after: element, by: firstIndex(of:))
    }
    
    mutating func move(elements: [Element], before element: Element) {
        _move(elements: elements, before: element, by: firstIndex(of:))
    }
}

extension RangeReplaceableCollection where Self: RandomAccessCollection, Element: Identifiable, Element: Equatable {
    
    mutating func move(elements: [Element], after element: Element) {
        _move(elements: elements, after: element, by: firstIndex(of:))
    }
    
    mutating func move(elements: [Element], before element: Element) {
        _move(elements: elements, before: element, by: firstIndex(of:))
    }
}

private extension RangeReplaceableCollection {
    mutating func _insert(elements: [Element], after element: Element, by getIndex: (Element) -> Index?) {
        guard var index = getIndex(element) else { return }
        index = self.index(after: index)
        replaceSubrange(index..<index, with: elements)
    }
    
    mutating func _insert(elements: [Element], before element: Element, by getIndex: (Element) -> Index?) {
        guard let index = getIndex(element) else { return }
        replaceSubrange(index..<index, with: elements)
    }
}

private extension RangeReplaceableCollection where Self: RandomAccessCollection {
    
    mutating func _move(elements: [Element], after element: Element, by getIndex: (Element) -> Index?) {
        guard var index = getIndex(element) else { return }
        index = self.index(after: index)
        for element in elements {
            if let currentIndex = getIndex(element) {
                if currentIndex <= index { index = self.index(before: index) }
                remove(at: currentIndex)
            }
            insert(element, at: index)
        }
    }
    
    mutating func _move(elements: [Element], before element: Element, by getIndex: (Element) -> Index?) {
        guard var index = getIndex(element) else { return }
        for element in elements {
            if let currentIndex = getIndex(element) {
                if currentIndex <= index { index = self.index(before: index) }
                remove(at: currentIndex)
            }
            insert(element, at: index)
        }
    }
}
