//
//  ListBuilder.swift
//  ListKit
//
//  Created by Frain on 2022/8/17.
//

@resultBuilder
public struct ListBuilder<Source: DataSource, View: ListView> where Source.AdapterBase == Source {
    public static func buildBlock(_ component: ListAdaptation<Source, View>) -> ListAdaptation<Source, View> {
        component
    }

    public static func buildBlock(_ components: ListAdaptation<Source, View>...) -> ListAdaptation<Source, View> {
        var base = components[0]
        for list in components.dropFirst() {
            base.listDelegate.formUnion(delegate: list.listDelegate)
        }
        return base
    }
}
