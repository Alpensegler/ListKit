//
//  AnyItemCollectionListBuilder.swift
//  ListKit
//
//  Created by Frain on 2019/12/11.
//

public typealias AnyItemCollectionList = CollectionList<AnyItemSource>

public protocol AnyItemCollectionListConvertible: CollectionListAdapter {
    init<Source: CollectionListAdapter>(_ dataSource: Source)
}

extension CollectionList: AnyItemCollectionListConvertible where SourceBase: AnyItemSourceConvertible {
    public init<Source: CollectionListAdapter>(_ dataSource: Source) {
        self = SourceBase(dataSource).toCollectionList()
    }
}

@_functionBuilder
public struct AnyItemCollectionListBuilder<AnyItemSource: AnyItemCollectionListConvertible> {
    public static func buildBlock<S0: CollectionListAdapter>(_ s0: S0) -> AnyItemSource {
        AnyItemSource(Sources(dataSources: [AnyItemSource(s0)]).toCollectionList())
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter>(_ s0: S0, _ s1: S1) -> AnyItemSource {
        AnyItemSource(Sources(dataSources: [AnyItemSource(s0), AnyItemSource(s1)]).toCollectionList())
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter, S2: CollectionListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2) -> AnyItemSource {
        AnyItemSource(Sources(dataSources: [AnyItemSource(s0), AnyItemSource(s1), AnyItemSource(s2)]).toCollectionList())
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter, S2: CollectionListAdapter, S3: CollectionListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3) -> AnyItemSource {
        AnyItemSource(Sources(dataSources: [AnyItemSource(s0), AnyItemSource(s1), AnyItemSource(s2), AnyItemSource(s3)]).toCollectionList())
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter, S2: CollectionListAdapter, S3: CollectionListAdapter, S4: CollectionListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4) -> AnyItemSource {
        AnyItemSource(Sources(dataSources: [AnyItemSource(s0), AnyItemSource(s1), AnyItemSource(s2), AnyItemSource(s3), AnyItemSource(s4)]).toCollectionList())
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter, S2: CollectionListAdapter, S3: CollectionListAdapter, S4: CollectionListAdapter, S5: CollectionListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5) -> AnyItemSource {
        AnyItemSource(Sources(dataSources: [AnyItemSource(s0), AnyItemSource(s1), AnyItemSource(s2), AnyItemSource(s3), AnyItemSource(s4), AnyItemSource(s5)]).toCollectionList())
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter, S2: CollectionListAdapter, S3: CollectionListAdapter, S4: CollectionListAdapter, S5: CollectionListAdapter, S6: CollectionListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6) -> AnyItemSource {
        AnyItemSource(Sources(dataSources: [AnyItemSource(s0), AnyItemSource(s1), AnyItemSource(s2), AnyItemSource(s3), AnyItemSource(s4), AnyItemSource(s5), AnyItemSource(s6)]).toCollectionList())
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter, S2: CollectionListAdapter, S3: CollectionListAdapter, S4: CollectionListAdapter, S5: CollectionListAdapter, S6: CollectionListAdapter, S7: CollectionListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7) -> AnyItemSource {
        AnyItemSource(Sources(dataSources: [AnyItemSource(s0), AnyItemSource(s1), AnyItemSource(s2), AnyItemSource(s3), AnyItemSource(s4), AnyItemSource(s5), AnyItemSource(s6), AnyItemSource(s7)]).toCollectionList())
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter, S2: CollectionListAdapter, S3: CollectionListAdapter, S4: CollectionListAdapter, S5: CollectionListAdapter, S6: CollectionListAdapter, S7: CollectionListAdapter, S8: CollectionListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7, _ s8: S8) -> AnyItemSource {
        AnyItemSource(Sources(dataSources: [AnyItemSource(s0), AnyItemSource(s1), AnyItemSource(s2), AnyItemSource(s3), AnyItemSource(s4), AnyItemSource(s5), AnyItemSource(s6), AnyItemSource(s7)]).toCollectionList())
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter, S2: CollectionListAdapter, S3: CollectionListAdapter, S4: CollectionListAdapter, S5: CollectionListAdapter, S6: CollectionListAdapter, S7: CollectionListAdapter, S8: CollectionListAdapter, S9: CollectionListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7, _ s8: S8, _ s9: S9) -> AnyItemSource {
        AnyItemSource(Sources(dataSources: [AnyItemSource(s8), AnyItemSource(s0), AnyItemSource(s1), AnyItemSource(s2), AnyItemSource(s3), AnyItemSource(s4), AnyItemSource(s5), AnyItemSource(s6), AnyItemSource(s7), AnyItemSource(s8), AnyItemSource(s9)]).toCollectionList())
    }
}

public extension AnyItemCollectionListConvertible {
    init(@AnyItemCollectionListBuilder<Self> content: () -> Self) {
        self = content()
    }
}
