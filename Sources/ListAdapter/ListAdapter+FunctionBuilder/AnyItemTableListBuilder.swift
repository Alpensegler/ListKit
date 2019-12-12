//
//  AnyItemTableListBuilder.swift
//  ListKit
//
//  Created by Frain on 2019/12/11.
//

public typealias AnyItemTableList = TableList<AnyItemSource>

public protocol AnyItemTableListConvertible: TableListAdapter {
    init<Source: TableListAdapter>(_ dataSource: Source)
}

extension TableList: AnyItemTableListConvertible where SourceBase: AnyItemSourceConvertible {
    public init<Source: TableListAdapter>(_ dataSource: Source) {
        self = SourceBase(dataSource).toTableList()
    }
}

@_functionBuilder
public struct AnyItemTableListBuilder<AnyItemSource: AnyItemTableListConvertible> {
    public static func buildBlock<S0: TableListAdapter>(_ s0: S0) -> AnyItemSource {
        AnyItemSource(Sources(dataSources: [AnyItemSource(s0)]).toTableList())
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter>(_ s0: S0, _ s1: S1) -> AnyItemSource {
        AnyItemSource(Sources(dataSources: [AnyItemSource(s0), AnyItemSource(s1)]).toTableList())
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter, S2: TableListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2) -> AnyItemSource {
        AnyItemSource(Sources(dataSources: [AnyItemSource(s0), AnyItemSource(s1), AnyItemSource(s2)]).toTableList())
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter, S2: TableListAdapter, S3: TableListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3) -> AnyItemSource {
        AnyItemSource(Sources(dataSources: [AnyItemSource(s0), AnyItemSource(s1), AnyItemSource(s2), AnyItemSource(s3)]).toTableList())
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter, S2: TableListAdapter, S3: TableListAdapter, S4: TableListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4) -> AnyItemSource {
        AnyItemSource(Sources(dataSources: [AnyItemSource(s0), AnyItemSource(s1), AnyItemSource(s2), AnyItemSource(s3), AnyItemSource(s4)]).toTableList())
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter, S2: TableListAdapter, S3: TableListAdapter, S4: TableListAdapter, S5: TableListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5) -> AnyItemSource {
        AnyItemSource(Sources(dataSources: [AnyItemSource(s0), AnyItemSource(s1), AnyItemSource(s2), AnyItemSource(s3), AnyItemSource(s4), AnyItemSource(s5)]).toTableList())
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter, S2: TableListAdapter, S3: TableListAdapter, S4: TableListAdapter, S5: TableListAdapter, S6: TableListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6) -> AnyItemSource {
        AnyItemSource(Sources(dataSources: [AnyItemSource(s0), AnyItemSource(s1), AnyItemSource(s2), AnyItemSource(s3), AnyItemSource(s4), AnyItemSource(s5), AnyItemSource(s6)]).toTableList())
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter, S2: TableListAdapter, S3: TableListAdapter, S4: TableListAdapter, S5: TableListAdapter, S6: TableListAdapter, S7: TableListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7) -> AnyItemSource {
        AnyItemSource(Sources(dataSources: [AnyItemSource(s0), AnyItemSource(s1), AnyItemSource(s2), AnyItemSource(s3), AnyItemSource(s4), AnyItemSource(s5), AnyItemSource(s6), AnyItemSource(s7)]).toTableList())
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter, S2: TableListAdapter, S3: TableListAdapter, S4: TableListAdapter, S5: TableListAdapter, S6: TableListAdapter, S7: TableListAdapter, S8: TableListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7, _ s8: S8) -> AnyItemSource {
        AnyItemSource(Sources(dataSources: [AnyItemSource(s0), AnyItemSource(s1), AnyItemSource(s2), AnyItemSource(s3), AnyItemSource(s4), AnyItemSource(s5), AnyItemSource(s6), AnyItemSource(s7)]).toTableList())
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter, S2: TableListAdapter, S3: TableListAdapter, S4: TableListAdapter, S5: TableListAdapter, S6: TableListAdapter, S7: TableListAdapter, S8: TableListAdapter, S9: TableListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7, _ s8: S8, _ s9: S9) -> AnyItemSource {
        AnyItemSource(Sources(dataSources: [AnyItemSource(s8), AnyItemSource(s0), AnyItemSource(s1), AnyItemSource(s2), AnyItemSource(s3), AnyItemSource(s4), AnyItemSource(s5), AnyItemSource(s6), AnyItemSource(s7), AnyItemSource(s8), AnyItemSource(s9)]).toTableList())
    }
}

public extension AnyItemTableListConvertible {
    init(@AnyItemTableListBuilder<Self> content: () -> Self) {
        self = content()
    }
}
