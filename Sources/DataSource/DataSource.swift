//
//  Source.swift
//  ListKit
//
//  Created by Frain on 2019/4/8.
//

public protocol DataSource<Model> {
    associatedtype Model = Any

    @SourceBuilder<Model>
    var source: any DataSource<Model> { get }
    var listCoordinator: ListCoordinator<Model> { get }
    var listCoordinatorContext: ListCoordinatorContext<Model> { get }
}

public extension DataSource {
    var listCoordinator: ListCoordinator<Model> { source.listCoordinator }
    var listCoordinatorContext: ListCoordinatorContext<Model> { source.listCoordinatorContext }
}

@resultBuilder
public struct SourceBuilder<Model> { }

public extension SourceBuilder where Model == Any {
    static func buildPartialBlock(first: any DataSource) -> any DataSource<Model> {
        first.pullback { $0 }
    }

    static func buildPartialBlock(accumulated: any DataSource, next: any DataSource) -> any DataSource<Model> {
        DataSources([accumulated.toAnyModel, next.toAnyModel])
    }

    static func buildEither(first component: any DataSource) -> any DataSource<Model> {
        component.pullback { $0 }
    }

    static func buildEither(second component: any DataSource) -> any DataSource<Model> {
        component.pullback { $0 }
    }

    static func buildArray(_ components: [some DataSource]) -> any DataSource<Model> {
        DataSources(components.map { WrapperDataSource(otherSource: $0) { $0 as Any } })
    }

    static func buildOptional<S: DataSource>(_ content: S?) -> any DataSource<Model> {
        content.pullback { $0 }
    }
}
