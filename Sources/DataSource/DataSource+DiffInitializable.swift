//
//  DataSource+DiffInitializable.swift
//  ListKit
//
//  Created by Frain on 2020/2/22.
//

public extension DataSource {
    var differ: Differ<SourceBase> { .none }
    var listUpdate: ListUpdate<Item> { .reload }
}

//Equatable
public extension DataSource where SourceBase: Equatable {
    var differ: Differ<SourceBase> { .diff }
}

public extension DataSource where SourceBase.Item: Equatable {
    var listUpdate: ListUpdate<Item> { .diff }
}

//Hashable
public extension DataSource where SourceBase: Hashable {
    var differ: Differ<SourceBase> { .diff }
}

public extension DataSource where SourceBase.Item: Hashable {
    var listUpdate: ListUpdate<Item> { .diff }
}

//Identifiable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase: Identifiable {
    var differ: Differ<SourceBase> { .diff }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase.Item: Identifiable {
    var listUpdate: ListUpdate<Item> { .diff }
}

//Identifiable + Equatable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase: Identifiable, SourceBase: Equatable {
    var differ: Differ<SourceBase> { .diff }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase.Item: Identifiable, SourceBase.Item: Equatable {
    var listUpdate: ListUpdate<Item> { .diff }
}

//Identifiable + Hashable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase: Identifiable, SourceBase: Hashable {
    var differ: Differ<SourceBase> { .diff }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase.Item: Identifiable, SourceBase.Item: Hashable {
    var listUpdate: ListUpdate<Item> { .diff }
}
