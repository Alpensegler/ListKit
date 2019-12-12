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
        let source = SourceBase(dataSource)
        self.init(source: source.sourceBase)
        coordinatorStorage.coordinator = source.listCoordinator
    }
}

@_functionBuilder
public struct AnyItemCollectionListBuilder<AnyItemCollectionList: AnyItemCollectionListConvertible> {
    public static func buildIf<S: CollectionListAdapter>(_ content: S?) -> AnyItemCollectionList {
        AnyItemCollectionList(content)
    }

    public static func buildEither<TrueContent: CollectionListAdapter>(first: TrueContent) -> AnyItemCollectionList {
        AnyItemCollectionList(first)
    }

    public static func buildEither<FalseContent: CollectionListAdapter>(second: FalseContent) -> AnyItemCollectionList {
        AnyItemCollectionList(second)
    }
    
    public static func buildBlock() -> AnyItemCollectionList {
        AnyItemCollectionList(Sources(dataSources: [AnyItemCollectionList]()).toCollectionList())
    }

    public static func buildBlock<S: CollectionListAdapter>(_ content: S) -> AnyItemCollectionList {
        AnyItemCollectionList(AnyItemCollectionList(content))
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter>(_ s0: S0, _ s1: S1) -> AnyItemCollectionList {
        AnyItemCollectionList(Sources(dataSources: [AnyItemCollectionList(s0), AnyItemCollectionList(s1)]).toCollectionList())
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter, S2: CollectionListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2) -> AnyItemCollectionList {
        AnyItemCollectionList(Sources(dataSources: [AnyItemCollectionList(s0), AnyItemCollectionList(s1), AnyItemCollectionList(s2)]).toCollectionList())
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter, S2: CollectionListAdapter, S3: CollectionListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3) -> AnyItemCollectionList {
        AnyItemCollectionList(Sources(dataSources: [AnyItemCollectionList(s0), AnyItemCollectionList(s1), AnyItemCollectionList(s2), AnyItemCollectionList(s3)]).toCollectionList())
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter, S2: CollectionListAdapter, S3: CollectionListAdapter, S4: CollectionListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4) -> AnyItemCollectionList {
        AnyItemCollectionList(Sources(dataSources: [AnyItemCollectionList(s0), AnyItemCollectionList(s1), AnyItemCollectionList(s2), AnyItemCollectionList(s3), AnyItemCollectionList(s4)]).toCollectionList())
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter, S2: CollectionListAdapter, S3: CollectionListAdapter, S4: CollectionListAdapter, S5: CollectionListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5) -> AnyItemCollectionList {
        AnyItemCollectionList(Sources(dataSources: [AnyItemCollectionList(s0), AnyItemCollectionList(s1), AnyItemCollectionList(s2), AnyItemCollectionList(s3), AnyItemCollectionList(s4), AnyItemCollectionList(s5)]).toCollectionList())
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter, S2: CollectionListAdapter, S3: CollectionListAdapter, S4: CollectionListAdapter, S5: CollectionListAdapter, S6: CollectionListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6) -> AnyItemCollectionList {
        AnyItemCollectionList(Sources(dataSources: [AnyItemCollectionList(s0), AnyItemCollectionList(s1), AnyItemCollectionList(s2), AnyItemCollectionList(s3), AnyItemCollectionList(s4), AnyItemCollectionList(s5), AnyItemCollectionList(s6)]).toCollectionList())
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter, S2: CollectionListAdapter, S3: CollectionListAdapter, S4: CollectionListAdapter, S5: CollectionListAdapter, S6: CollectionListAdapter, S7: CollectionListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7) -> AnyItemCollectionList {
        AnyItemCollectionList(Sources(dataSources: [AnyItemCollectionList(s0), AnyItemCollectionList(s1), AnyItemCollectionList(s2), AnyItemCollectionList(s3), AnyItemCollectionList(s4), AnyItemCollectionList(s5), AnyItemCollectionList(s6), AnyItemCollectionList(s7)]).toCollectionList())
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter, S2: CollectionListAdapter, S3: CollectionListAdapter, S4: CollectionListAdapter, S5: CollectionListAdapter, S6: CollectionListAdapter, S7: CollectionListAdapter, S8: CollectionListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7, _ s8: S8) -> AnyItemCollectionList {
        AnyItemCollectionList(Sources(dataSources: [AnyItemCollectionList(s0), AnyItemCollectionList(s1), AnyItemCollectionList(s2), AnyItemCollectionList(s3), AnyItemCollectionList(s4), AnyItemCollectionList(s5), AnyItemCollectionList(s6), AnyItemCollectionList(s7)]).toCollectionList())
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter, S2: CollectionListAdapter, S3: CollectionListAdapter, S4: CollectionListAdapter, S5: CollectionListAdapter, S6: CollectionListAdapter, S7: CollectionListAdapter, S8: CollectionListAdapter, S9: CollectionListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7, _ s8: S8, _ s9: S9) -> AnyItemCollectionList {
        AnyItemCollectionList(Sources(dataSources: [AnyItemCollectionList(s8), AnyItemCollectionList(s0), AnyItemCollectionList(s1), AnyItemCollectionList(s2), AnyItemCollectionList(s3), AnyItemCollectionList(s4), AnyItemCollectionList(s5), AnyItemCollectionList(s6), AnyItemCollectionList(s7), AnyItemCollectionList(s8), AnyItemCollectionList(s9)]).toCollectionList())
    }
}

public extension AnyItemCollectionListConvertible {
    init(@AnyItemCollectionListBuilder<Self> content: () -> Self) {
        self = content()
    }
}
