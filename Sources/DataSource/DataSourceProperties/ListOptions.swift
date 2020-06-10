//
//  ListOptions.swift
//  ListKit
//
//  Created by Frain on 2020/6/9.
//

public protocol Options: OptionSet where RawValue == Int8 {
    associatedtype SourceBase
}

public struct ListOptions<SourceBase> {
    public private(set) var rawValue: Int8
    var differ: Differ<SourceBase>?
}

extension ListOptions: Options {
    public init(rawValue: Int8) { self.rawValue = rawValue }
    
    public mutating func formUnion(_ other: Self) {
        rawValue = rawValue | other.rawValue
        differ = differ ?? other.differ
    }
    
    @discardableResult
    public mutating func insert(_ newMember: Self) -> (inserted: Bool, memberAfterInsert: Self) {
        formUnion(newMember)
        return (true, self)
    }
}

extension ListOptions: DiffInitializable {
    public static var none: ListOptions<SourceBase> { .init() }
    
    public static func diff(
        by areEquivalent: @escaping (SourceBase, SourceBase) -> Bool
    ) -> ListOptions<SourceBase> {
        .init(rawValue: 0, differ: .init(areEquivalent: areEquivalent))
    }
    
    public static func diff<ID: Hashable>(
        id: @escaping (SourceBase) -> ID
    ) -> ListOptions<SourceBase> {
        .init(rawValue: 0, differ: .init(identifier: id))
    }
    
    public static func diff<ID: Hashable>(
        id: @escaping (SourceBase) -> ID,
        by areEquivalent: @escaping (SourceBase, SourceBase) -> Bool
    ) -> ListOptions<SourceBase> {
        .init(rawValue: 0, differ: .init(identifier: id, areEquivalent: areEquivalent))
    }
    
    init<OtherSourceBase>(
        _ other: ListOptions<OtherSourceBase>,
        cast: @escaping (Value) -> (OtherSourceBase) = { $0 as! OtherSourceBase }
    ) {
        rawValue = other.rawValue
        differ = other.differ.map { .init($0, cast: cast) }
    }
    
    init<OtherOptions: Options>(id: AnyHashable?, _ other: OtherOptions) {
        rawValue = other.rawValue
        differ = id.map { id in .init(identifier: { _ in id }) }
    }
}
