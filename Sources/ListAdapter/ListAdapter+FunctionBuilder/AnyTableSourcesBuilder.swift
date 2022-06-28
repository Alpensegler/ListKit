//
//  AnyTableSourcesBuilder.swift
//  ListKit
//
//  Created by Frain on 2019/12/11.
//

public typealias AnyTableSources = TableList<AnySources>

public extension TableList where Source == AnySources {
    convenience init<Source: TableListAdapter>(
        options: ListOptions = .init(),
        @AnyTableSourcesBuilder content: () -> Source
    ) {
        self.init(content(), options: options)
    }
}

@resultBuilder
public struct AnyTableSourcesBuilder {
    public static func buildIf(_ content: AnyTableSources?) -> AnyTableSources {
        .init(content)
    }
    
    public static func buildEither<TrueContent: TableListAdapter>(first: TrueContent) -> AnyTableSources {
        .init(first)
    }
    
    public static func buildEither<FalseContent: TableListAdapter>(second: FalseContent) -> AnyTableSources {
        .init(second)
    }

    public static func buildBlock<S: TableListAdapter>(_ content: S) -> AnyTableSources {
        .init(content)
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter>(_ s0: S0, _ s1: S1) -> AnyTableSources {
        .init(Sources(dataSources: [AnyTableSources(s0), AnyTableSources(s1)]))
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter, S2: TableListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2) -> AnyTableSources {
        .init(Sources(dataSources: [AnyTableSources(s0), AnyTableSources(s1), AnyTableSources(s2)]))
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter, S2: TableListAdapter, S3: TableListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3) -> AnyTableSources {
        .init(Sources(dataSources: [AnyTableSources(s0), AnyTableSources(s1), AnyTableSources(s2), AnyTableSources(s3)]))
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter, S2: TableListAdapter, S3: TableListAdapter, S4: TableListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4) -> AnyTableSources {
        .init(Sources(dataSources: [AnyTableSources(s0), AnyTableSources(s1), AnyTableSources(s2), AnyTableSources(s3), AnyTableSources(s4)]))
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter, S2: TableListAdapter, S3: TableListAdapter, S4: TableListAdapter, S5: TableListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5) -> AnyTableSources {
        .init(Sources(dataSources: [AnyTableSources(s0), AnyTableSources(s1), AnyTableSources(s2), AnyTableSources(s3), AnyTableSources(s4), AnyTableSources(s5)]))
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter, S2: TableListAdapter, S3: TableListAdapter, S4: TableListAdapter, S5: TableListAdapter, S6: TableListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6) -> AnyTableSources {
        .init(Sources(dataSources: [AnyTableSources(s0), AnyTableSources(s1), AnyTableSources(s2), AnyTableSources(s3), AnyTableSources(s4), AnyTableSources(s5), AnyTableSources(s6)]))
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter, S2: TableListAdapter, S3: TableListAdapter, S4: TableListAdapter, S5: TableListAdapter, S6: TableListAdapter, S7: TableListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7) -> AnyTableSources {
        .init(Sources(dataSources: [AnyTableSources(s0), AnyTableSources(s1), AnyTableSources(s2), AnyTableSources(s3), AnyTableSources(s4), AnyTableSources(s5), AnyTableSources(s6), AnyTableSources(s7)]))
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter, S2: TableListAdapter, S3: TableListAdapter, S4: TableListAdapter, S5: TableListAdapter, S6: TableListAdapter, S7: TableListAdapter, S8: TableListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7, _ s8: S8) -> AnyTableSources {
        .init(Sources(dataSources: [AnyTableSources(s0), AnyTableSources(s1), AnyTableSources(s2), AnyTableSources(s3), AnyTableSources(s4), AnyTableSources(s5), AnyTableSources(s6), AnyTableSources(s7), AnyTableSources(s8)]))
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter, S2: TableListAdapter, S3: TableListAdapter, S4: TableListAdapter, S5: TableListAdapter, S6: TableListAdapter, S7: TableListAdapter, S8: TableListAdapter, S9: TableListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7, _ s8: S8, _ s9: S9) -> AnyTableSources {
        .init(Sources(dataSources: [AnyTableSources(s0), AnyTableSources(s1), AnyTableSources(s2), AnyTableSources(s3), AnyTableSources(s4), AnyTableSources(s5), AnyTableSources(s6), AnyTableSources(s7), AnyTableSources(s8), AnyTableSources(s9)]))
    }
}
