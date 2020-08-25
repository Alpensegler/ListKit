//
//  NSDataSource.swift
//  ListKit
//
//  Created by Frain on 2019/12/5.
//

import Foundation

public protocol NSDataSource: AnyObject, UpdatableDataSource where Source == [Int] {
    func item(at indexPath: IndexPath) -> Item
    func numbersOfSections() -> Int
    func numbersOfItem(in section: Int) -> Int
}

public extension NSDataSource {
    var source: [Int] {
        let section = numbersOfSections()
        if section == 0 { return [] }
        return (0..<section).map { numbersOfItem(in: $0) }
    }
}
