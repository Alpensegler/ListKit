//
//  AnyItemSourceBuilder.swift
//  ListKit
//
//  Created by Frain on 2019/12/11.
//

@_functionBuilder
public struct AnyItemSourceBuilder<AnyItemSource: AnyItemSourceConvertible> {
    public static func buildIf<S: DataSource>(_ content: S?) -> AnyItemSource {
        AnyItemSource(content)
    }

    public static func buildEither<TrueContent: DataSource>(first: TrueContent) -> AnyItemSource {
        AnyItemSource(first)
    }

    public static func buildEither<FalseContent: DataSource>(second: FalseContent) -> AnyItemSource {
        AnyItemSource(second)
    }
    
    public static func buildBlock() -> AnyItemSource {
        AnyItemSource(Sources(dataSources: [AnyItemSource]()))
    }
    
    public static func buildBlock<S: DataSource>(_ content: S) -> AnyItemSource {
        AnyItemSource(AnyItemSource(content))
    }
    
    public static func buildBlock<S0: DataSource, S1: DataSource>(_ s0: S0, _ s1: S1) -> AnyItemSource {
        AnyItemSource(Sources(dataSources: [AnyItemSource(s0), AnyItemSource(s1)]))
    }
    
    public static func buildBlock<S0: DataSource, S1: DataSource, S2: DataSource>(_ s0: S0, _ s1: S1, _ s2: S2) -> AnyItemSource {
        AnyItemSource(Sources(dataSources: [AnyItemSource(s0), AnyItemSource(s1), AnyItemSource(s2)]))
    }
    
    public static func buildBlock<S0: DataSource, S1: DataSource, S2: DataSource, S3: DataSource>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3) -> AnyItemSource {
        AnyItemSource(Sources(dataSources: [AnyItemSource(s0), AnyItemSource(s1), AnyItemSource(s2), AnyItemSource(s3)]))
    }
    
    public static func buildBlock<S0: DataSource, S1: DataSource, S2: DataSource, S3: DataSource, S4: DataSource>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4) -> AnyItemSource {
        AnyItemSource(Sources(dataSources: [AnyItemSource(s0), AnyItemSource(s1), AnyItemSource(s2), AnyItemSource(s3), AnyItemSource(s4)]))
    }
    
    public static func buildBlock<S0: DataSource, S1: DataSource, S2: DataSource, S3: DataSource, S4: DataSource, S5: DataSource>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5) -> AnyItemSource {
        AnyItemSource(Sources(dataSources: [AnyItemSource(s0), AnyItemSource(s1), AnyItemSource(s2), AnyItemSource(s3), AnyItemSource(s4), AnyItemSource(s5)]))
    }
    
    public static func buildBlock<S0: DataSource, S1: DataSource, S2: DataSource, S3: DataSource, S4: DataSource, S5: DataSource, S6: DataSource>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6) -> AnyItemSource {
        AnyItemSource(Sources(dataSources: [AnyItemSource(s0), AnyItemSource(s1), AnyItemSource(s2), AnyItemSource(s3), AnyItemSource(s4), AnyItemSource(s5), AnyItemSource(s6)]))
    }
    
    public static func buildBlock<S0: DataSource, S1: DataSource, S2: DataSource, S3: DataSource, S4: DataSource, S5: DataSource, S6: DataSource, S7: DataSource>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7) -> AnyItemSource {
        AnyItemSource(Sources(dataSources: [AnyItemSource(s0), AnyItemSource(s1), AnyItemSource(s2), AnyItemSource(s3), AnyItemSource(s4), AnyItemSource(s5), AnyItemSource(s6), AnyItemSource(s7)]))
    }
    
    public static func buildBlock<S0: DataSource, S1: DataSource, S2: DataSource, S3: DataSource, S4: DataSource, S5: DataSource, S6: DataSource, S7: DataSource, S8: DataSource>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7, _ s8: S8) -> AnyItemSource {
        AnyItemSource(Sources(dataSources: [AnyItemSource(s0), AnyItemSource(s1), AnyItemSource(s2), AnyItemSource(s3), AnyItemSource(s4), AnyItemSource(s5), AnyItemSource(s6), AnyItemSource(s7)]))
    }
    
    public static func buildBlock<S0: DataSource, S1: DataSource, S2: DataSource, S3: DataSource, S4: DataSource, S5: DataSource, S6: DataSource, S7: DataSource, S8: DataSource, S9: DataSource>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7, _ s8: S8, _ s9: S9) -> AnyItemSource {
        AnyItemSource(Sources(dataSources: [AnyItemSource(s8), AnyItemSource(s0), AnyItemSource(s1), AnyItemSource(s2), AnyItemSource(s3), AnyItemSource(s4), AnyItemSource(s5), AnyItemSource(s6), AnyItemSource(s7), AnyItemSource(s8), AnyItemSource(s9)]))
    }
}

public extension RangeReplaceableCollection where Element: AnyItemSourceConvertible {
    init(@AnyItemSourceBuilder<Element> content: () -> [Element]) {
        self.init(content())
    }
}

public extension AnyItemSourceConvertible {
    init(@AnyItemSourceBuilder<Self> content: () -> Self) {
        self = content()
    }
}
