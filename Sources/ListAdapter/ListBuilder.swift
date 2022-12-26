//
//  ListBuilder.swift
//  ListKit
//
//  Created by Frain on 2022/8/17.
//

@resultBuilder
public struct ListBuilder<Model, View: ListView> { }

public extension ListBuilder where Model == Any {
    static func buildPartialBlock<Other>(first: some ListAdapter<Other, View>) -> ListAdaptation<Model, View> {
        ListAdaptation(first.pullback { $0 })
    }

    static func buildPartialBlock<Other, OtherNext>(accumulated: some ListAdapter<Other, View>, next: some ListAdapter<OtherNext, View>) -> ListAdaptation<Model, View> {
        ListAdaptation(DataSources([accumulated.toAnyModel, next.toAnyModel]))
    }

    static func buildEither<Other>(first component: some ListAdapter<Other, View>) -> ListAdaptation<Model, View> {
        ListAdaptation(component.pullback { $0 })
    }

    static func buildEither<Other>(second component: some ListAdapter<Other, View>) -> ListAdaptation<Model, View> {
        ListAdaptation(component.pullback { $0 })
    }

    static func buildArray<Other>(_ components: [some ListAdapter<Other, View>]) -> ListAdaptation<Model, View> {
        ListAdaptation(DataSources(components.map { WrapperDataSource(otherSource: $0) { $0 as Any } }))
    }

    static func buildOptional<Other, S: ListAdapter<Other, View>>(_ component: S?) -> S? {
        component
    }
}
