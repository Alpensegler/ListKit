//
//  Collection+Extension.swift
//  ListKit
//
//  Created by Frain on 2019/10/15.
//

extension Collection {
    func mapContiguous<T>(_ transform: (Element) throws -> T) rethrows -> ContiguousArray<T> {
        let count = count
        if count == 0 { return [] }

        var result = ContiguousArray<T>()
        result.reserveCapacity(count)

        var index = startIndex

        for _ in 0..<count {
            result.append(try transform(self[index]))
            formIndex(after: &index)
        }

        return result
    }

    func compactMapContiguous<T>(_ transform: (Element) throws -> T?) rethrows -> ContiguousArray<T> {
        let count = count
        if count == 0 { return [] }

        var result = ContiguousArray<T>()
        result.reserveCapacity(count)

        var index = startIndex

        for _ in 0..<count {
            defer { formIndex(after: &index) }
            guard let value = try transform(self[index]) else { continue }
            result.append(value)
        }

        return result
    }
}

extension RangeReplaceableCollection {
    subscript(safe index: Index) -> Element? {
        guard startIndex <= index, index < endIndex else { return nil }
        return self[index]
    }

    mutating func append(repeatElement element: Element, count: Int) {
        guard count > 0 else { return }
        append(contentsOf: repeatElement(element, count: count))
    }

    init(capacity: Int) {
        self.init()
        reserveCapacity(capacity)
    }

    init(repeatElement element: Element, count: Int) {
        self.init(repeatElement(element, count: count))
    }
}
