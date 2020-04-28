//
//  AnyCollectionSourcesBuilder.swift
//  ListKit
//
//  Created by Frain on 2019/12/11.
//

public typealias AnyCollectionSources = CollectionList<AnySources>

public extension CollectionList where SourceBase == AnySources {
    init<Source: CollectionListAdapter>(_ dataSource: Source) {
        self.init(AnySources(dataSource.collectionList))
    }
    
    init<Source: CollectionListAdapter>(@AnyCollectionSourcesBuilder content: () -> Source) {
        self.init(content())
    }
}

@_functionBuilder
public struct AnyCollectionSourcesBuilder {
    public static func buildIf<S: CollectionListAdapter>(_ content: S?) -> S? {
        content
    }

    public static func buildEither<TrueContent: CollectionListAdapter>(first: TrueContent) -> TrueContent {
        first
    }

    public static func buildEither<FalseContent: CollectionListAdapter>(second: FalseContent) -> FalseContent {
        second
    }
    
    public static func buildBlock() -> CollectionList<Sources<[AnyCollectionSources], Any>> {
        CollectionList(Sources(dataSources: []))
    }

    public static func buildBlock<S: CollectionListAdapter>(_ content: S) -> S {
        content
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter>(_ s0: S0, _ s1: S1) -> CollectionList<Sources<[AnyCollectionSources], Any>> {
        CollectionList(Sources(dataSources: [AnyCollectionSources(s0), AnyCollectionSources(s1)]))
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter, S2: CollectionListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2) -> CollectionList<Sources<[AnyCollectionSources], Any>> {
        CollectionList(Sources(dataSources: [AnyCollectionSources(s0), AnyCollectionSources(s1), AnyCollectionSources(s2)]))
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter, S2: CollectionListAdapter, S3: CollectionListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3) -> CollectionList<Sources<[AnyCollectionSources], Any>> {
        CollectionList(Sources(dataSources: [AnyCollectionSources(s0), AnyCollectionSources(s1), AnyCollectionSources(s2), AnyCollectionSources(s3)]))
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter, S2: CollectionListAdapter, S3: CollectionListAdapter, S4: CollectionListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4) -> CollectionList<Sources<[AnyCollectionSources], Any>> {
        CollectionList(Sources(dataSources: [AnyCollectionSources(s0), AnyCollectionSources(s1), AnyCollectionSources(s2), AnyCollectionSources(s3), AnyCollectionSources(s4)]))
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter, S2: CollectionListAdapter, S3: CollectionListAdapter, S4: CollectionListAdapter, S5: CollectionListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5) -> CollectionList<Sources<[AnyCollectionSources], Any>> {
        CollectionList(Sources(dataSources: [AnyCollectionSources(s0), AnyCollectionSources(s1), AnyCollectionSources(s2), AnyCollectionSources(s3), AnyCollectionSources(s4), AnyCollectionSources(s5)]))
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter, S2: CollectionListAdapter, S3: CollectionListAdapter, S4: CollectionListAdapter, S5: CollectionListAdapter, S6: CollectionListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6) -> CollectionList<Sources<[AnyCollectionSources], Any>> {
        CollectionList(Sources(dataSources: [AnyCollectionSources(s0), AnyCollectionSources(s1), AnyCollectionSources(s2), AnyCollectionSources(s3), AnyCollectionSources(s4), AnyCollectionSources(s5), AnyCollectionSources(s6)]))
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter, S2: CollectionListAdapter, S3: CollectionListAdapter, S4: CollectionListAdapter, S5: CollectionListAdapter, S6: CollectionListAdapter, S7: CollectionListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7) -> CollectionList<Sources<[AnyCollectionSources], Any>> {
        CollectionList(Sources(dataSources: [AnyCollectionSources(s0), AnyCollectionSources(s1), AnyCollectionSources(s2), AnyCollectionSources(s3), AnyCollectionSources(s4), AnyCollectionSources(s5), AnyCollectionSources(s6), AnyCollectionSources(s7)]))
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter, S2: CollectionListAdapter, S3: CollectionListAdapter, S4: CollectionListAdapter, S5: CollectionListAdapter, S6: CollectionListAdapter, S7: CollectionListAdapter, S8: CollectionListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7, _ s8: S8) -> CollectionList<Sources<[AnyCollectionSources], Any>> {
        CollectionList(Sources(dataSources: [AnyCollectionSources(s0), AnyCollectionSources(s1), AnyCollectionSources(s2), AnyCollectionSources(s3), AnyCollectionSources(s4), AnyCollectionSources(s5), AnyCollectionSources(s6), AnyCollectionSources(s7), AnyCollectionSources(s8)]))
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter, S2: CollectionListAdapter, S3: CollectionListAdapter, S4: CollectionListAdapter, S5: CollectionListAdapter, S6: CollectionListAdapter, S7: CollectionListAdapter, S8: CollectionListAdapter, S9: CollectionListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7, _ s8: S8, _ s9: S9) -> CollectionList<Sources<[AnyCollectionSources], Any>> {
        CollectionList(Sources(dataSources: [AnyCollectionSources(s0), AnyCollectionSources(s1), AnyCollectionSources(s2), AnyCollectionSources(s3), AnyCollectionSources(s4), AnyCollectionSources(s5), AnyCollectionSources(s6), AnyCollectionSources(s7), AnyCollectionSources(s8), AnyCollectionSources(s9)]))
    }
}
