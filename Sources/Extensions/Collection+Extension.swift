//
//  Collection+Extension.swift
//  ListKit
//
//  Created by Frain on 2019/10/15.
//

extension Collection {
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

extension RangeReplaceableCollection {
    subscript(safe index: Index) -> Element? {
        guard startIndex <= index, index < endIndex else { return nil }
        return self[index]
    }
}

extension ContiguousArray {
    init(capacity: Int) {
        self.init()
        reserveCapacity(capacity)
    }
}
