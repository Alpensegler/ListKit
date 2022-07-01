//
//  DataSource.swift
//  ListKit
//
//  Created by Frain on 2019/4/8.
//

/// A type representing the datasource of a list
public protocol DataSource<Source, Item> {
    /// A type representing the model of a single cell
    associatedtype Item
    
    /// The type of datasource representing the content of the list
    associatedtype Source = [Item]
    
    /// A replacement of `Self`
    associatedtype Base: DataSource = Self
    where Base.Item == Item, Base.Base == Base
    
    /// The content and behavior of the list
    @SourceBuilder<Base>
    var source: Source { get }
    
    /// The base of the datasource, euqal to `Self` in normal cases
    var base: Base { get }
    
    #if !Next
    associatedtype AdapterBase: DataSource = Self
        where AdapterBase.Item == Item, AdapterBase.AdapterBase == AdapterBase
    
    var adapterBase: AdapterBase { get }
    
    var listOptions: ListOptions { get }
    var listUpdate: ListUpdate<SourceBase>.Whole { get }
    var listDiffer: ListDiffer<SourceBase> { get }
    
    var listDelegate: ListDelegate { get }
    var listCoordinator: ListCoordinator<SourceBase> { get }
    var listCoordinatorContext: ListCoordinatorContext<SourceBase> { get }
    #endif
}

public extension DataSource where Base == Self {
    var base: Base { self }
}

#if !Next
public extension DataSource {
    var listDelegate: ListDelegate { .init() }
    var listCoordinator: ListCoordinator<SourceBase> {
        fatalError("unsupported source \(Source.self) item \(Item.self)")
    }
    var listCoordinatorContext: ListCoordinatorContext<SourceBase> {
        ListCoordinatorContext(listCoordinator, listDelegate: listDelegate)
    }
}

public extension DataSource where AdapterBase == Self {
    var adapterBase: AdapterBase { self }
}
#endif
