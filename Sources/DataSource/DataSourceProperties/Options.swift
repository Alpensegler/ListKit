//
//  Options.swift
//  ListKit
//
//  Created by Frain on 2020/6/11.
//

public protocol Options: OptionSet where RawValue == Int8 {
    associatedtype SourceBase
}

public extension Options {
    static var preferNoAnimation: Self { .init(rawValue: 1 << 0) }
}

public extension Options
where
    SourceBase: DataSource,
    SourceBase.SourceBase == SourceBase,
    SourceBase.Item == SourceBase.Source
{
    static var preferSection: Self { .init(rawValue: 1 << 1) }
}

public extension Options
where
    SourceBase: DataSource,
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: Collection,
    SourceBase.Item == SourceBase.Source.Element
{
    static var preferSection: Self { .init(rawValue: 1 << 1) }
    static var keepEmptySection: Self { .init(rawValue: 1 << 2) }
}

public extension Options
where
    SourceBase: DataSource,
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: DataSource,
    SourceBase.Source.Element.SourceBase.Item == SourceBase.Item
{
    static var preferSection: Self { .init(rawValue: 1 << 1) }
    static var keepEmptySection: Self { .init(rawValue: 1 << 2) }
}

extension Options where Element == Self {
    var preferSection: Bool { contains(.init(rawValue: 1 << 1)) }
    var keepEmptySection: Bool { contains(.init(rawValue: 1 << 2))  }
}
