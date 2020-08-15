//
//  DataSource+Properties.swift
//  ListKit
//
//  Created by Frain on 2020/2/22.
//

public extension DataSource {
    var listDiffer: ListDiffer<SourceBase> { .none }
    var listOptions: ListOptions<SourceBase> { .none }
    var listUpdate: ListUpdate<SourceBase>.Whole { .reload }
}

//Equatable
public extension DataSource where SourceBase: Equatable {
    var listDiffer: ListDiffer<SourceBase> { .diff }
}

public extension DataSource where SourceBase.Item: Equatable {
    var listUpdate: ListUpdate<SourceBase>.Whole { .diff }
}

//Hashable
public extension DataSource where SourceBase: Hashable {
    var listDiffer: ListDiffer<SourceBase> { .diff }
}

public extension DataSource where SourceBase.Item: Hashable {
    var listUpdate: ListUpdate<SourceBase>.Whole { .diff }
}

//Identifiable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase: Identifiable {
    var listDiffer: ListDiffer<SourceBase> { .diff }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase.Item: Identifiable {
    var listUpdate: ListUpdate<SourceBase>.Whole { .diff }
}

//Identifiable + Equatable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase: Identifiable, SourceBase: Equatable {
    var listDiffer: ListDiffer<SourceBase> { .diff }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase.Item: Identifiable, SourceBase.Item: Equatable {
    var listUpdate: ListUpdate<SourceBase>.Whole { .diff }
}

//Identifiable + Hashable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase: Identifiable, SourceBase: Hashable {
    var listDiffer: ListDiffer<SourceBase> { .diff }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase.Item: Identifiable, SourceBase.Item: Hashable {
    var listUpdate: ListUpdate<SourceBase>.Whole { .diff }
}

//Object
public extension DataSource where SourceBase: AnyObject {
    var listDiffer: ListDiffer<SourceBase> { .diff(id: { ObjectIdentifier($0) }) }
}

//Object + Equatable
public extension DataSource where SourceBase: AnyObject, SourceBase: Equatable {
    var listDiffer: ListDiffer<SourceBase> { .diff }
}

//Object + Hashable
public extension DataSource where SourceBase: AnyObject, SourceBase: Hashable {
    var listDiffer: ListDiffer<SourceBase> { .diff }
}

//Subupdate
public extension DataSource where SourceBase.Source: DataSource, SourceBase.Item == Any {
    var listUpdate: ListUpdate<SourceBase>.Whole { .subupdate }
}

public extension DataSource
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: DataSource,
    SourceBase.Source.Element.SourceBase.Item == SourceBase.Item,
    SourceBase.Item == Any
{
    var listUpdate: ListUpdate<SourceBase>.Whole { .subupdate }
}
