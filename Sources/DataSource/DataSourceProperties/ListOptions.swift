//
//  ListOptions.swift
//  ListKit
//
//  Created by Frain on 2020/6/9.
//

public struct ListOptions<SourceBase>: OptionSet {
    public private(set) var rawValue: Int8
    
    public init(rawValue: Int8) { self.rawValue = rawValue }
}

public extension ListOptions {
    static var none: Self { .init() }
    static var preferNoAnimation: Self { .init(rawValue: 1 << 0) }
    static var preferSection: Self { .init(rawValue: 1 << 1) }
    static var keepEmptySection: Self { .init(rawValue: 1 << 2) }
}

extension ListOptions {
    var preferSection: Bool { contains(.init(rawValue: 1 << 1)) }
    var keepEmptySection: Bool { contains(.init(rawValue: 1 << 2))  }
    
    init<OtherSourceBase>(_ otherOptions: ListOptions<OtherSourceBase>) {
        rawValue = otherOptions.rawValue
    }
}
