//
//  AnyDataSource.swift
//  ListKit
//
//  Created by Frain on 2022/12/26.
//

public struct AnyDataSource<Model>: DataSource {
    public var source: any DataSource<Model>
}

public extension AnyDataSource {
    init(@SourceBuilder<Model> build: () -> any DataSource<Model>) {
        self.source = build()
    }
}

public struct AnyListAdapter<Model, View: ListView>: ListAdapter {
    public var source: any DataSource<Model>
    public var list: ListAdaptation<Model, View>
}

public extension AnyListAdapter {
    init(@ListBuilder<Model, View> build: () -> ListAdaptation<Model, View>) {
        let content = build()
        self.source = content
        self.list = content
    }
}

public extension ListAdapter {
    typealias AnyListAdapter = ListKit.AnyListAdapter<Model, View>
}

struct WrapperDataSource<Model, Wrapped>: DataSource {
    var otherSource: any DataSource<Wrapped>
    var source: any DataSource<Model> { return self }
    var toModel: (Wrapped) -> Model
    var listCoordinator: ListCoordinator<Model> {
        WrapperCoordinator(options: .init(), toModel: toModel, otherContext: otherSource.listCoordinatorContext)
    }
    var listCoordinatorContext: ListCoordinatorContext<Model> { .init(listCoordinator) }
}

extension DataSource {
    var toAny: AnyDataSource<Model> {
        .init(source: self)
    }

    var toAnyModel: AnyDataSource<Any> {
        .init(source: pullback { $0 as Any })
    }
}

public extension DataSource {
    func pullback<Other>(_ block: @escaping (Model) -> Other) -> any DataSource<Other> {
        WrapperDataSource(otherSource: self, toModel: block)
    }
}
