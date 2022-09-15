//
//  ModelCachedDataSource.swift
//  ListKit
//
//  Created by Frain on 2021/1/5.
//

// swiftlint:disable opening_brace

public extension DataSource where SourceBase == Self {
    func withModelCached<ModelCache>(
        cacheForModel: @escaping (Model) -> ModelCache
    ) -> ModelCached<SourceBase, ModelCache> {
        .init(sourceBase, cacheForModel: cacheForModel)
    }
}

public protocol ModelCachedDataSource: DataSource {
    associatedtype ModelCache

    var modelCached: ModelCached<SourceBase, ModelCache> { get }
}

@propertyWrapper
@dynamicMemberLookup
public struct ModelCached<Base: DataSource, ModelCache>: ModelCachedDataSource
where Base.SourceBase == Base {
    public typealias Model = Base.Model
    public typealias Source = Base.Source
    public typealias SourceBase = Base.SourceBase

    public var source: Source { sourceBase.source }
    public var sourceBase: Base
    public var listDelegate: ListDelegate

    public var modelCached: ModelCached<Base, ModelCache> { self }
    public var listCoordinatorContext: ListCoordinatorContext<Base> {
        sourceBase.listCoordinatorContext
    }

    public var wrappedValue: Base {
        get { sourceBase }
        set { sourceBase = newValue }
    }

    public subscript<Value>(dynamicMember path: KeyPath<Base, Value>) -> Value {
        sourceBase[keyPath: path]
    }

    public subscript<Value>(dynamicMember path: WritableKeyPath<Base, Value>) -> Value {
        get { sourceBase[keyPath: path] }
        set { sourceBase[keyPath: path] = newValue }
    }

    init(_ sourceBase: Base, cacheForModel: Any? = nil) {
        var delegate = sourceBase.listDelegate
        delegate.getCache = cacheForModel
        self.listDelegate = delegate
        self.sourceBase = sourceBase
    }
}

//public extension ModelCachedDataSource
//where
//    SourceBase.Source: DataSource,
//    SourceBase.Source.SourceBase == AnySources,
//    SourceBase.Model == Any
//{
//    var modelCached: ModelCached<SourceBase, ModelCache> { .init(sourceBase) }
//}

public extension ModelCachedDataSource
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: ModelCachedDataSource,
    SourceBase.Source.Element.SourceBase.Model == SourceBase.Model,
    SourceBase.Source.Element.ModelCache == ModelCache
{
    var modelCached: ModelCached<SourceBase, ModelCache> { .init(sourceBase) }
}

#if canImport(CoreGraphics)
import CoreGraphics
public typealias ModelHeightCached<Base: DataSource> = ModelCached<Base, CGFloat> where Base.SourceBase == Base
public typealias ModelSizeCached<Base: DataSource> = ModelCached<Base, CGSize> where Base.SourceBase == Base
#endif
