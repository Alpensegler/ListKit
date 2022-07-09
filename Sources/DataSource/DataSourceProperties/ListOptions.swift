//
//  ListOptions.swift
//  ListKit
//
//  Created by Frain on 2020/6/9.
//

public struct ListOptions: OptionSet {
    public private(set) var rawValue: Int8

    public init(rawValue: Int8) { self.rawValue = rawValue }
}

public extension ListOptions {
    static let none = ListOptions()
    static let preferNoAnimation = ListOptions(rawValue: 1 << 0)
    static let preferSection = ListOptions(rawValue: 1 << 1)
    static let removeEmptySection = ListOptions(rawValue: 1 << 2)
}

extension ListOptions {
    var preferSection: Bool { contains(.preferSection) }
    var removeEmptySection: Bool { contains(.removeEmptySection)  }
    var preferNoAnimation: Bool { contains(.preferNoAnimation) }
}
