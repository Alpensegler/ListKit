//
//  DataSourceBuilder.swift
//  ListKit
//
//  Created by Frain on 2022/6/23.
//

/// List datasource constructor
@resultBuilder
public enum DataSourceBuilder<Base: DataSource> {
    public typealias Expression = Base.Item
    public typealias Component = Base.Source
    
    static func buildBlock() -> Component { fatalError() }
    static func buildExpression(_ expression: Expression) -> Component {
        guard let expression = expression as? Component else {
            fatalError("cannot cast \(type(of: expression)) to \(Component.self)")
        }
        return expression
    }
}
