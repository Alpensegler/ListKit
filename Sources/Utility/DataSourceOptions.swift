//
//  DataSourceOptions.swift
//  ListKit
//
//  Created by Frain on 2020/5/24.
//

public struct DataSourceOptions: OptionSet {
    public let rawValue: Int8
    
    public init(rawValue: Int8) {
        self.rawValue = rawValue
    }
}

public extension DataSourceOptions {
    static var preferSection: Self { .init(rawValue: 1 << 0) }
    static var keepSectionIfEmpty: Self { .init(rawValue: 1 << 1) }
}
