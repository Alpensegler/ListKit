//
//  DataSource+DiffInitializable.swift
//  ListKit
//
//  Created by Frain on 2020/2/22.
//

public extension DataSource {
    var listOptions: ListOptions<SourceBase> { .none }
    var listUpdate: ListUpdate<Item> { .reload }
}

//Equatable
public extension DataSource where SourceBase: Equatable {
    var listOptions: ListOptions<SourceBase> { .diff }
}

public extension DataSource where SourceBase.Item: Equatable {
    var listUpdate: ListUpdate<Item> { .diff }
}

//Hashable
public extension DataSource where SourceBase: Hashable {
    var listOptions: ListOptions<SourceBase> { .diff }
}

public extension DataSource where SourceBase.Item: Hashable {
    var listUpdate: ListUpdate<Item> { .diff }
}

//Identifiable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase: Identifiable {
    var listOptions: ListOptions<SourceBase> { .diff }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase.Item: Identifiable {
    var listUpdate: ListUpdate<Item> { .diff }
}

//Identifiable + Equatable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase: Identifiable, SourceBase: Equatable {
    var listOptions: ListOptions<SourceBase> { .diff }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase.Item: Identifiable, SourceBase.Item: Equatable {
    var listUpdate: ListUpdate<Item> { .diff }
}

//Identifiable + Hashable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase: Identifiable, SourceBase: Hashable {
    var listOptions: ListOptions<SourceBase> { .diff }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase.Item: Identifiable, SourceBase.Item: Hashable {
    var listUpdate: ListUpdate<Item> { .diff }
}

//Object
public extension DataSource where SourceBase: AnyObject {
    var listOptions: ListOptions<SourceBase> { .diff(id: { ObjectIdentifier($0) }) }
}

//Object + Equatable
public extension DataSource where SourceBase: AnyObject, SourceBase: Equatable {
    var listOptions: ListOptions<SourceBase> { .diff }
}

//Object + Hashable
public extension DataSource where SourceBase: AnyObject, SourceBase: Hashable {
    var listOptions: ListOptions<SourceBase> { .diff }
}
