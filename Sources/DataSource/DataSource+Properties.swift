//
//  DataSource+Properties.swift
//  ListKit
//
//  Created by Frain on 2020/2/22.
//

// swiftlint:disable opening_brace

public extension DataSource {
    var listDiffer: ListDiffer<SourceBase> { .none }
    var listOptions: ListOptions { .none }
    var listUpdate: ListUpdate<SourceBase>.Whole { .reload }
}

// MARK: - Equatable
public extension DataSource where SourceBase: Equatable {
    var listDiffer: ListDiffer<SourceBase> { .diff }
}

public extension DataSource where SourceBase.Model: Equatable {
    var listUpdate: ListUpdate<SourceBase>.Whole { .diff }
}

// MARK: - Hashable
public extension DataSource where SourceBase: Hashable {
    var listDiffer: ListDiffer<SourceBase> { .diff }
}

public extension DataSource where SourceBase.Model: Hashable {
    var listUpdate: ListUpdate<SourceBase>.Whole { .diff }
}

//// MARK: - Identifiable
//@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
//public extension DataSource where SourceBase: Identifiable {
//    var listDiffer: ListDiffer<SourceBase> { .diff }
//}
//
//@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
//public extension DataSource where SourceBase.Model: Identifiable {
//    var listUpdate: ListUpdate<SourceBase>.Whole { .diff }
//}
//
//// MARK: - Identifiable + Equatable
//@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
//public extension DataSource where SourceBase: Identifiable, SourceBase: Equatable {
//    var listDiffer: ListDiffer<SourceBase> { .diff }
//}
//
//@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
//public extension DataSource where SourceBase.Model: Identifiable, SourceBase.Model: Equatable {
//    var listUpdate: ListUpdate<SourceBase>.Whole { .diff }
//}
//
//// MARK: - Identifiable + Hashable
//@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
//public extension DataSource where SourceBase: Identifiable, SourceBase: Hashable {
//    var listDiffer: ListDiffer<SourceBase> { .diff }
//}
//
//@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
//public extension DataSource where SourceBase.Model: Identifiable, SourceBase.Model: Hashable {
//    var listUpdate: ListUpdate<SourceBase>.Whole { .diff }
//}

// MARK: - Object
public extension DataSource where SourceBase: AnyObject {
    var listDiffer: ListDiffer<SourceBase> { .diff(id: { ObjectIdentifier($0) }) }
}

// MARK: - Object + Equatable
public extension DataSource where SourceBase: AnyObject, SourceBase: Equatable {
    var listDiffer: ListDiffer<SourceBase> { .diff }
}

// MARK: - Object + Hashable
public extension DataSource where SourceBase: AnyObject, SourceBase: Hashable {
    var listDiffer: ListDiffer<SourceBase> { .diff }
}

// MARK: - Subupdate
//public extension DataSource
//where
//    SourceBase.Source: DataSource,
//    SourceBase.Source.SourceBase == AnySources,
//    SourceBase.Model == Any
//{
//    var listUpdate: ListUpdate<SourceBase>.Whole { .subupdate }
//}

public extension DataSource
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: DataSource,
    SourceBase.Source.Element.SourceBase.Model == SourceBase.Model,
    SourceBase.Model == Any
{
    var listUpdate: ListUpdate<SourceBase>.Whole { .subupdate }
}
