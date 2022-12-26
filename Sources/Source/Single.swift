//
//  Single.swift
//  ListKit
//
//  Created by Frain on 2022/12/26.
//

@propertyWrapper
public struct Single<Model>: DataSource {
    public var listOptions = ListOptions()
    public var source: any DataSource<Model> { return self }
    public var listCoordinator: ListCoordinator<Model> { ModelCoordinator(source: wrappedValue, options: listOptions) }
    public var listCoordinatorContext: ListCoordinatorContext<Model> { .init(listCoordinator) }
    public var wrappedValue: Model

    public init(_ model: Model) {
        self.wrappedValue = model
    }

    public init(wrappedValue: Model) {
        self.wrappedValue = wrappedValue
    }
}
