//
//  ConditionalSources.swift
//  ListKit
//
//  Created by Frain on 2020/9/3.
//

public enum ConditionalSources<TrueContent: DataSource, FalseContent: DataSource>: DataSource {
    public typealias Item = Any
    public typealias SourceBase = Self
    
    case trueContent(TrueContent)
    case falseContent(FalseContent)
    
    public var source: [AnySources] {
        switch self {
        case let .trueContent(content): return [.init(content)]
        case let .falseContent(content): return [.init(content)]
        }
    }
    
    public var listDiffer: ListDiffer<ConditionalSources<TrueContent, FalseContent>> {
        switch self {
        case let .trueContent(content):
            return .init(content.listDiffer) { _ in content.sourceBase }
        case let .falseContent(content):
            return .init(content.listDiffer) { _ in content.sourceBase }
        }
    }
    
    public var listOptions: ListOptions {
        switch self {
        case let .trueContent(content): return content.listOptions
        case let .falseContent(content): return content.listOptions
        }
    }
    
    public var listUpdate: ListUpdate<ConditionalSources<TrueContent, FalseContent>>.Whole {
        switch self {
        case let .trueContent(content):
            return content.listUpdate.diff.map { .init(diff: .init($0)) } ?? .reload
        case let .falseContent(content):
            return content.listUpdate.diff.map { .init(diff: .init($0)) } ?? .reload
        }
    }
}


extension ConditionalSources: ScrollListAdapter
where TrueContent: ScrollListAdapter, FalseContent: ScrollListAdapter { }

extension ConditionalSources: TableListAdapter
where TrueContent: TableListAdapter, FalseContent: TableListAdapter {
    public var tableList: TableList<ConditionalSources<TrueContent, FalseContent>> {
        .init(self)
    }
}

extension ConditionalSources: CollectionListAdapter
where TrueContent: CollectionListAdapter, FalseContent: CollectionListAdapter {
    public var collectionList: CollectionList<ConditionalSources<TrueContent, FalseContent>> {
        .init(self)
    }
}
