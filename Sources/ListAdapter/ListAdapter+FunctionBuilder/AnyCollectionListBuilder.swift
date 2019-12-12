//
//  AnyCollectionListBuilder.swift
//  ListKit
//
//  Created by Frain on 2019/12/11.
//

public typealias AnyCollectionList<Item> = CollectionList<AnySource<Item>>

public protocol AnyCollectionListConvertible: CollectionListAdapter {
    init<Source: CollectionListAdapter>(_ dataSource: Source) where Source.SourceBase.Item == Item
}

extension CollectionList: AnyCollectionListConvertible where SourceBase: AnySourceConvertible {
    public init<Source: CollectionListAdapter>(_ dataSource: Source) where Item == Source.Item {
        let source = SourceBase(dataSource)
        self.init(source: source.sourceBase)
        coordinatorStorage.coordinator = source.listCoordinator
    }
}

@_functionBuilder
public struct AnyCollectionListBuilder<AnyCollectionList: AnyCollectionListConvertible> {
    public static func buildIf<S: CollectionListAdapter>(_ content: S?) -> AnyCollectionList where S.Item == AnyCollectionList.Item {
        AnyCollectionList(content)
    }

    public static func buildEither<TrueContent: CollectionListAdapter>(first: TrueContent) -> AnyCollectionList where TrueContent.Item == AnyCollectionList.Item {
        AnyCollectionList(first)
    }

    public static func buildEither<FalseContent: CollectionListAdapter>(second: FalseContent) -> AnyCollectionList where FalseContent.Item == AnyCollectionList.Item {
        AnyCollectionList(second)
    }
    
    public static func buildBlock() -> AnyCollectionList {
        AnyCollectionList(Sources(dataSources: [AnyCollectionList]()).toCollectionList())
    }
    
    public static func buildBlock<S: CollectionListAdapter>(_ content: S) -> AnyCollectionList where S.Item == AnyCollectionList.Item {
        AnyCollectionList(AnyCollectionList(content))
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter>(_ s0: S0, _ s1: S1) -> AnyCollectionList where S0.Item == AnyCollectionList.Item, S1.Item == AnyCollectionList.Item {
        AnyCollectionList(Sources(dataSources: [AnyCollectionList(s0), AnyCollectionList(s1)]).toCollectionList())
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter, S2: CollectionListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2) -> AnyCollectionList where S0.Item == AnyCollectionList.Item, S1.Item == AnyCollectionList.Item, S2.Item == AnyCollectionList.Item {
        AnyCollectionList(Sources(dataSources: [AnyCollectionList(s0), AnyCollectionList(s1), AnyCollectionList(s2)]).toCollectionList())
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter, S2: CollectionListAdapter, S3: CollectionListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3) -> AnyCollectionList where S0.Item == AnyCollectionList.Item, S1.Item == AnyCollectionList.Item, S2.Item == AnyCollectionList.Item, S3.Item == AnyCollectionList.Item {
        AnyCollectionList(Sources(dataSources: [AnyCollectionList(s0), AnyCollectionList(s1), AnyCollectionList(s2), AnyCollectionList(s3)]).toCollectionList())
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter, S2: CollectionListAdapter, S3: CollectionListAdapter, S4: CollectionListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4) -> AnyCollectionList where S0.Item == AnyCollectionList.Item, S1.Item == AnyCollectionList.Item, S2.Item == AnyCollectionList.Item, S3.Item == AnyCollectionList.Item, S4.Item == AnyCollectionList.Item {
        AnyCollectionList(Sources(dataSources: [AnyCollectionList(s0), AnyCollectionList(s1), AnyCollectionList(s2), AnyCollectionList(s3), AnyCollectionList(s4)]).toCollectionList())
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter, S2: CollectionListAdapter, S3: CollectionListAdapter, S4: CollectionListAdapter, S5: CollectionListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5) -> AnyCollectionList where S0.Item == AnyCollectionList.Item, S1.Item == AnyCollectionList.Item, S2.Item == AnyCollectionList.Item, S3.Item == AnyCollectionList.Item, S4.Item == AnyCollectionList.Item, S5.Item == AnyCollectionList.Item {
        AnyCollectionList(Sources(dataSources: [AnyCollectionList(s0), AnyCollectionList(s1), AnyCollectionList(s2), AnyCollectionList(s3), AnyCollectionList(s4), AnyCollectionList(s5)]).toCollectionList())
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter, S2: CollectionListAdapter, S3: CollectionListAdapter, S4: CollectionListAdapter, S5: CollectionListAdapter, S6: CollectionListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6) -> AnyCollectionList where S0.Item == AnyCollectionList.Item, S1.Item == AnyCollectionList.Item, S2.Item == AnyCollectionList.Item, S3.Item == AnyCollectionList.Item, S4.Item == AnyCollectionList.Item, S5.Item == AnyCollectionList.Item, S6.Item == AnyCollectionList.Item {
        AnyCollectionList(Sources(dataSources: [AnyCollectionList(s0), AnyCollectionList(s1), AnyCollectionList(s2), AnyCollectionList(s3), AnyCollectionList(s4), AnyCollectionList(s5), AnyCollectionList(s6)]).toCollectionList())
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter, S2: CollectionListAdapter, S3: CollectionListAdapter, S4: CollectionListAdapter, S5: CollectionListAdapter, S6: CollectionListAdapter, S7: CollectionListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7) -> AnyCollectionList where S0.Item == AnyCollectionList.Item, S1.Item == AnyCollectionList.Item, S2.Item == AnyCollectionList.Item, S3.Item == AnyCollectionList.Item, S4.Item == AnyCollectionList.Item, S5.Item == AnyCollectionList.Item, S7.Item == AnyCollectionList.Item, S6.Item == AnyCollectionList.Item {
        AnyCollectionList(Sources(dataSources: [AnyCollectionList(s0), AnyCollectionList(s1), AnyCollectionList(s2), AnyCollectionList(s3), AnyCollectionList(s4), AnyCollectionList(s5), AnyCollectionList(s6), AnyCollectionList(s7)]).toCollectionList())
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter, S2: CollectionListAdapter, S3: CollectionListAdapter, S4: CollectionListAdapter, S5: CollectionListAdapter, S6: CollectionListAdapter, S7: CollectionListAdapter, S8: CollectionListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7, _ s8: S8) -> AnyCollectionList where S0.Item == AnyCollectionList.Item, S1.Item == AnyCollectionList.Item, S2.Item == AnyCollectionList.Item, S3.Item == AnyCollectionList.Item, S4.Item == AnyCollectionList.Item, S5.Item == AnyCollectionList.Item, S7.Item == AnyCollectionList.Item, S6.Item == AnyCollectionList.Item, S8.Item == AnyCollectionList.Item {
        AnyCollectionList(Sources(dataSources: [AnyCollectionList(s0), AnyCollectionList(s1), AnyCollectionList(s2), AnyCollectionList(s3), AnyCollectionList(s4), AnyCollectionList(s5), AnyCollectionList(s6), AnyCollectionList(s7)]).toCollectionList())
    }
    
    public static func buildBlock<S0: CollectionListAdapter, S1: CollectionListAdapter, S2: CollectionListAdapter, S3: CollectionListAdapter, S4: CollectionListAdapter, S5: CollectionListAdapter, S6: CollectionListAdapter, S7: CollectionListAdapter, S8: CollectionListAdapter, S9: CollectionListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7, _ s8: S8, _ s9: S9) -> AnyCollectionList where S0.Item == AnyCollectionList.Item, S1.Item == AnyCollectionList.Item, S2.Item == AnyCollectionList.Item, S3.Item == AnyCollectionList.Item, S4.Item == AnyCollectionList.Item, S5.Item == AnyCollectionList.Item, S7.Item == AnyCollectionList.Item, S6.Item == AnyCollectionList.Item, S8.Item == AnyCollectionList.Item, S9.Item == AnyCollectionList.Item {
        AnyCollectionList(Sources(dataSources: [AnyCollectionList(s8), AnyCollectionList(s0), AnyCollectionList(s1), AnyCollectionList(s2), AnyCollectionList(s3), AnyCollectionList(s4), AnyCollectionList(s5), AnyCollectionList(s6), AnyCollectionList(s7), AnyCollectionList(s8), AnyCollectionList(s9)]).toCollectionList())
    }
}

public extension AnyCollectionListConvertible {
    init(@AnyCollectionListBuilder<Self> content: () -> Self) {
        self = content()
    }
}
