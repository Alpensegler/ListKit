//
//  NSDataSource.swift
//  ListKit
//
//  Created by Frain on 2019/12/5.
//

// swiftlint:disable comment_spacing

//import Foundation
//
//public protocol NSDataSource: AnyObject, UpdatableDataSource where Source == [Int] {
//    func model(at indexPath: IndexPath) -> Model
//    func numbersOfSections() -> Int
//    func numbersOfModel(in section: Int) -> Int
//}
//
//public extension NSDataSource {
//    var source: [Int] {
//        let section = numbersOfSections()
//        if section == 0 { return [] }
//        return (0..<section).map { numbersOfModel(in: $0) }
//    }
//}
