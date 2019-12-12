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
public struct AnyItemTableListBuilder<AnyItemTableList: AnyItemTableListConvertible> {
    public static func buildIf<S: TableListAdapter>(_ content: S?) -> AnyItemTableList {
        AnyItemTableList(content)
    }

    public static func buildEither<TrueContent: TableListAdapter>(first: TrueContent) -> AnyItemTableList {
        AnyItemTableList(first)
    }

    public static func buildEither<FalseContent: TableListAdapter>(second: FalseContent) -> AnyItemTableList {
        AnyItemTableList(second)
    }
    
    public static func buildBlock() -> AnyItemTableList {
        AnyItemTableList(Sources(dataSources: [AnyItemTableList]()).toTableList())
    }

    public static func buildBlock<S: TableListAdapter>(_ content: S) -> AnyItemTableList {
        AnyItemTableList(AnyItemTableList(content))
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter>(_ s0: S0, _ s1: S1) -> AnyItemTableList {
        AnyItemTableList(Sources(dataSources: [AnyItemTableList(s0), AnyItemTableList(s1)]).toTableList())
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter, S2: TableListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2) -> AnyItemTableList {
        AnyItemTableList(Sources(dataSources: [AnyItemTableList(s0), AnyItemTableList(s1), AnyItemTableList(s2)]).toTableList())
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter, S2: TableListAdapter, S3: TableListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3) -> AnyItemTableList {
        AnyItemTableList(Sources(dataSources: [AnyItemTableList(s0), AnyItemTableList(s1), AnyItemTableList(s2), AnyItemTableList(s3)]).toTableList())
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter, S2: TableListAdapter, S3: TableListAdapter, S4: TableListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4) -> AnyItemTableList {
        AnyItemTableList(Sources(dataSources: [AnyItemTableList(s0), AnyItemTableList(s1), AnyItemTableList(s2), AnyItemTableList(s3), AnyItemTableList(s4)]).toTableList())
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter, S2: TableListAdapter, S3: TableListAdapter, S4: TableListAdapter, S5: TableListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5) -> AnyItemTableList {
        AnyItemTableList(Sources(dataSources: [AnyItemTableList(s0), AnyItemTableList(s1), AnyItemTableList(s2), AnyItemTableList(s3), AnyItemTableList(s4), AnyItemTableList(s5)]).toTableList())
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter, S2: TableListAdapter, S3: TableListAdapter, S4: TableListAdapter, S5: TableListAdapter, S6: TableListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6) -> AnyItemTableList {
        AnyItemTableList(Sources(dataSources: [AnyItemTableList(s0), AnyItemTableList(s1), AnyItemTableList(s2), AnyItemTableList(s3), AnyItemTableList(s4), AnyItemTableList(s5), AnyItemTableList(s6)]).toTableList())
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter, S2: TableListAdapter, S3: TableListAdapter, S4: TableListAdapter, S5: TableListAdapter, S6: TableListAdapter, S7: TableListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7) -> AnyItemTableList {
        AnyItemTableList(Sources(dataSources: [AnyItemTableList(s0), AnyItemTableList(s1), AnyItemTableList(s2), AnyItemTableList(s3), AnyItemTableList(s4), AnyItemTableList(s5), AnyItemTableList(s6), AnyItemTableList(s7)]).toTableList())
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter, S2: TableListAdapter, S3: TableListAdapter, S4: TableListAdapter, S5: TableListAdapter, S6: TableListAdapter, S7: TableListAdapter, S8: TableListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7, _ s8: S8) -> AnyItemTableList {
        AnyItemTableList(Sources(dataSources: [AnyItemTableList(s0), AnyItemTableList(s1), AnyItemTableList(s2), AnyItemTableList(s3), AnyItemTableList(s4), AnyItemTableList(s5), AnyItemTableList(s6), AnyItemTableList(s7)]).toTableList())
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter, S2: TableListAdapter, S3: TableListAdapter, S4: TableListAdapter, S5: TableListAdapter, S6: TableListAdapter, S7: TableListAdapter, S8: TableListAdapter, S9: TableListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7, _ s8: S8, _ s9: S9) -> AnyItemTableList {
        AnyItemTableList(Sources(dataSources: [AnyItemTableList(s8), AnyItemTableList(s0), AnyItemTableList(s1), AnyItemTableList(s2), AnyItemTableList(s3), AnyItemTableList(s4), AnyItemTableList(s5), AnyItemTableList(s6), AnyItemTableList(s7), AnyItemTableList(s8), AnyItemTableList(s9)]).toTableList())
    }
}

public extension AnyItemTableListConvertible {
    init(@AnyItemTableListBuilder<Self> content: () -> Self) {
        self = content()
    }
}
