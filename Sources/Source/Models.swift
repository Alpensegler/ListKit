//
//  ModelsSources.swift
//  ListKit
//
//  Created by Frain on 2022/10/28.
//

@propertyWrapper
public struct Models<C: Collection>: DataSource {
    public typealias Model = C.Element

    public var listOptions = ListOptions()
    public var source: any DataSource<Model> { return self }
    public var listCoordinator: ListCoordinator<Model> { ModelsCoordinator(source: wrappedValue, options: listOptions) }
    public var listCoordinatorContext: ListCoordinatorContext<Model> { .init(listCoordinator) }
    public var wrappedValue: C

    public init(_ models: C) {
        self.wrappedValue = models
    }

    public init(wrappedValue: C) {
        self.wrappedValue = wrappedValue
    }
}
