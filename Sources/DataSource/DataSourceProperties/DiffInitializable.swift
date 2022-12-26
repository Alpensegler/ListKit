//
//  DiffInitializable.swift
//  ListKit
//
//  Created by Frain on 2020/2/22.
//

//public protocol DiffInitializable {
//    associatedtype Value
//
//    static func diff(by areEquivalent: @escaping (Value, Value) -> Bool) -> Self
//    static func diff<ID: Hashable>(id: @escaping (Value) -> ID) -> Self
//    static func diff<ID: Hashable>(
//        id: @escaping (Value) -> ID,
//        by areEquivalent: @escaping (Value, Value) -> Bool
//    ) -> Self
//}
//
//// MARK: - Value Equatable
//public extension DiffInitializable where Value: Equatable {
//    static var diff: Self { diff(by: ==) }
//    static func diff<ID: Hashable>(id: @escaping (Value) -> ID) -> Self { diff(id: id, by: ==) }
//}
//
//// MARK: - Value Hashable
//public extension DiffInitializable where Value: Hashable {
//    static var diff: Self { diff(id: { $0 }) }
//}
//
//// MARK: - Value Identifiable
//@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
//public extension DiffInitializable where Value: Identifiable {
//    static var diff: Self { diff(id: \.id) }
//    static func diff(by areEquivalent: @escaping (Value, Value) -> Bool) -> Self {
//        diff(id: \.id, by: areEquivalent)
//    }
//}
//
//// MARK: - Value Identifiable + Equatable
//@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
//public extension DiffInitializable where Value: Identifiable, Value: Equatable {
//    static var diff: Self { diff(id: \.id, by: ==) }
//}
//
//// MARK: - Value Identifiable + Hashable
//@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
//public extension DiffInitializable where Value: Identifiable, Value: Hashable {
//    static var diff: Self { diff(id: \.id, by: ==) }
//}
