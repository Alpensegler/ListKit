//
//  AnySourceBuilder.swift
//  ListKit
//
//  Created by Frain on 2019/12/11.
//

@_functionBuilder
public struct AnySourceBuilder<AnySource: AnySourceConvertible> {
    public static func buildIf<S: DataSource>(_ content: S?) -> AnySource where S.Item == AnySource.Item {
        AnySource(content)
    }

    public static func buildEither<TrueContent: DataSource>(first: TrueContent) -> AnySource where TrueContent.Item == AnySource.Item {
        AnySource(first)
    }

    public static func buildEither<FalseContent: DataSource>(second: FalseContent) -> AnySource where FalseContent.Item == AnySource.Item {
        AnySource(second)
    }
    
    public static func buildBlock() -> AnySource {
        AnySource(Sources(dataSources: [AnySource]()))
    }
    
    public static func buildBlock<S0: DataSource>(_ content: S0) -> AnySource where S0.Item == AnySource.Item {
        AnySource(AnySource(content))
    }
    
    public static func buildBlock<S0: DataSource, S1: DataSource>(_ s0: S0, _ s1: S1) -> AnySource where S0.Item == AnySource.Item, S1.Item == AnySource.Item {
        AnySource(Sources(dataSources: [AnySource(s0), AnySource(s1)]))
    }
    
    public static func buildBlock<S0: DataSource, S1: DataSource, S2: DataSource>(_ s0: S0, _ s1: S1, _ s2: S2) -> AnySource where S0.Item == AnySource.Item, S1.Item == AnySource.Item, S2.Item == AnySource.Item {
        AnySource(Sources(dataSources: [AnySource(s0), AnySource(s1), AnySource(s2)]))
    }
    
    public static func buildBlock<S0: DataSource, S1: DataSource, S2: DataSource, S3: DataSource>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3) -> AnySource where S0.Item == AnySource.Item, S1.Item == AnySource.Item, S2.Item == AnySource.Item, S3.Item == AnySource.Item {
        AnySource(Sources(dataSources: [AnySource(s0), AnySource(s1), AnySource(s2), AnySource(s3)]))
    }
    
    public static func buildBlock<S0: DataSource, S1: DataSource, S2: DataSource, S3: DataSource, S4: DataSource>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4) -> AnySource where S0.Item == AnySource.Item, S1.Item == AnySource.Item, S2.Item == AnySource.Item, S3.Item == AnySource.Item, S4.Item == AnySource.Item {
        AnySource(Sources(dataSources: [AnySource(s0), AnySource(s1), AnySource(s2), AnySource(s3), AnySource(s4)]))
    }
    
    public static func buildBlock<S0: DataSource, S1: DataSource, S2: DataSource, S3: DataSource, S4: DataSource, S5: DataSource>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5) -> AnySource where S0.Item == AnySource.Item, S1.Item == AnySource.Item, S2.Item == AnySource.Item, S3.Item == AnySource.Item, S4.Item == AnySource.Item, S5.Item == AnySource.Item {
        AnySource(Sources(dataSources: [AnySource(s0), AnySource(s1), AnySource(s2), AnySource(s3), AnySource(s4), AnySource(s5)]))
    }
    
    public static func buildBlock<S0: DataSource, S1: DataSource, S2: DataSource, S3: DataSource, S4: DataSource, S5: DataSource, S6: DataSource>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6) -> AnySource where S0.Item == AnySource.Item, S1.Item == AnySource.Item, S2.Item == AnySource.Item, S3.Item == AnySource.Item, S4.Item == AnySource.Item, S5.Item == AnySource.Item, S6.Item == AnySource.Item {
        AnySource(Sources(dataSources: [AnySource(s0), AnySource(s1), AnySource(s2), AnySource(s3), AnySource(s4), AnySource(s5), AnySource(s6)]))
    }
    
    public static func buildBlock<S0: DataSource, S1: DataSource, S2: DataSource, S3: DataSource, S4: DataSource, S5: DataSource, S6: DataSource, S7: DataSource>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7) -> AnySource where S0.Item == AnySource.Item, S1.Item == AnySource.Item, S2.Item == AnySource.Item, S3.Item == AnySource.Item, S4.Item == AnySource.Item, S5.Item == AnySource.Item, S7.Item == AnySource.Item, S6.Item == AnySource.Item {
        AnySource(Sources(dataSources: [AnySource(s0), AnySource(s1), AnySource(s2), AnySource(s3), AnySource(s4), AnySource(s5), AnySource(s6), AnySource(s7)]))
    }
    
    public static func buildBlock<S0: DataSource, S1: DataSource, S2: DataSource, S3: DataSource, S4: DataSource, S5: DataSource, S6: DataSource, S7: DataSource, S8: DataSource>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7, _ s8: S8) -> AnySource where S0.Item == AnySource.Item, S1.Item == AnySource.Item, S2.Item == AnySource.Item, S3.Item == AnySource.Item, S4.Item == AnySource.Item, S5.Item == AnySource.Item, S7.Item == AnySource.Item, S6.Item == AnySource.Item, S8.Item == AnySource.Item {
        AnySource(Sources(dataSources: [AnySource(s0), AnySource(s1), AnySource(s2), AnySource(s3), AnySource(s4), AnySource(s5), AnySource(s6), AnySource(s7)]))
    }
    
    public static func buildBlock<S0: DataSource, S1: DataSource, S2: DataSource, S3: DataSource, S4: DataSource, S5: DataSource, S6: DataSource, S7: DataSource, S8: DataSource, S9: DataSource>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7, _ s8: S8, _ s9: S9) -> AnySource where S0.Item == AnySource.Item, S1.Item == AnySource.Item, S2.Item == AnySource.Item, S3.Item == AnySource.Item, S4.Item == AnySource.Item, S5.Item == AnySource.Item, S7.Item == AnySource.Item, S6.Item == AnySource.Item, S8.Item == AnySource.Item, S9.Item == AnySource.Item {
        AnySource(Sources(dataSources: [AnySource(s8), AnySource(s0), AnySource(s1), AnySource(s2), AnySource(s3), AnySource(s4), AnySource(s5), AnySource(s6), AnySource(s7), AnySource(s8), AnySource(s9)]))
    }
}

public extension AnySourceConvertible {
    init(@AnySourceBuilder<Self> content: () -> Self) {
        self = content()
    }
}

func foo() -> AnySource<Int> {
    AnySource<Int> {
        Sources(items: [1, 2, 3])
        Sources(items: [1, 2, 3])
    }
}


