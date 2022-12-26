//
//  DataSources.swift
//  ListKit
//
//  Created by Frain on 2022/12/26.
//

@propertyWrapper
public struct DataSources<C: RangeReplaceableCollection, Model>: DataSource
where C.Element: DataSource, C.Element.Model == Model {
    public var listOptions = ListOptions()
    public var source: any DataSource<Model> { return self }
    public var listCoordinator: ListCoordinator<Model> {
        SourcesCoordinator(wrappedValue, listOptions: listOptions)
    }
    public var listCoordinatorContext: ListCoordinatorContext<Model> {
        .init(listCoordinator)
    }
    public var wrappedValue: C

    public init(_ dataSources: C) {
        self.wrappedValue = dataSources
    }

    public init(wrappedValue: C) {
        self.wrappedValue = wrappedValue
    }
}
