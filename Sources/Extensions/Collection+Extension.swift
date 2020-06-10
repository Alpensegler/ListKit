//
//  Collection+Extension.swift
//  ListKit
//
//  Created by Frain on 2019/10/15.
//

extension Collection {
    var nonNilFirst: Element { self[startIndex] }

    func mapContiguous<T>(_ transform: (Element) throws -> T) rethrows -> ContiguousArray<T> {
        let n = count
        if n == 0 { return [] }
        
        var result = ContiguousArray<T>()
        result.reserveCapacity(n)
        
        var i = startIndex
        
        for _ in 0..<n {
            result.append(try transform(self[i]))
            formIndex(after: &i)
        }
        
        return result
    }

    func compactMapContiguous<T>(
        _ transform: (Element) throws -> T?
    ) rethrows -> ContiguousArray<T> {
        let n = count
        if n == 0 { return [] }
        
        var result = ContiguousArray<T>()
        result.reserveCapacity(n)
        
        var i = startIndex
        
        for _ in 0..<n {
            guard let value = try transform(self[i]) else { continue }
            result.append(value)
            formIndex(after: &i)
        }
        
        return result
    }
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
