//
//  AnySourcesBuilder.swift
//  ListKit
//
//  Created by Frain on 2019/12/11.
//

public extension AnySources {
    init<Source: DataSource>(_ dataSources: [Source]) {
        self.init(Sources(dataSources: dataSources))
    }
    
    init(@AnySourcesBuilder content: () -> AnySources) {
        self = content()
    }
}

@_functionBuilder
public struct AnySourcesBuilder {
    public static func buildIf<S: DataSource>(_ content: S?) -> AnySources {
        AnySources(content)
    }

    public static func buildEither<TrueContent: DataSource>(first: TrueContent) -> AnySources {
        AnySources(first)
    }

    public static func buildEither<FalseContent: DataSource>(second: FalseContent) -> AnySources {
        AnySources(second)
    }
    
    public static func buildBlock() -> AnySources {
        AnySources([AnySources]())
    }
    
    public static func buildBlock<S: DataSource>(_ content: S) -> AnySources {
        AnySources(AnySources(content))
    }
    
    public static func buildBlock<S0: DataSource, S1: DataSource>(_ s0: S0, _ s1: S1) -> AnySources {
        AnySources([AnySources(s0), AnySources(s1)])
    }
    
    public static func buildBlock<S0: DataSource, S1: DataSource, S2: DataSource>(_ s0: S0, _ s1: S1, _ s2: S2) -> AnySources {
        AnySources([AnySources(s0), AnySources(s1), AnySources(s2)])
    }
    
    public static func buildBlock<S0: DataSource, S1: DataSource, S2: DataSource, S3: DataSource>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3) -> AnySources {
        AnySources([AnySources(s0), AnySources(s1), AnySources(s2), AnySources(s3)])
    }
    
    public static func buildBlock<S0: DataSource, S1: DataSource, S2: DataSource, S3: DataSource, S4: DataSource>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4) -> AnySources {
        AnySources([AnySources(s0), AnySources(s1), AnySources(s2), AnySources(s3), AnySources(s4)])
    }
    
    public static func buildBlock<S0: DataSource, S1: DataSource, S2: DataSource, S3: DataSource, S4: DataSource, S5: DataSource>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5) -> AnySources {
        AnySources([AnySources(s0), AnySources(s1), AnySources(s2), AnySources(s3), AnySources(s4), AnySources(s5)])
    }
    
    public static func buildBlock<S0: DataSource, S1: DataSource, S2: DataSource, S3: DataSource, S4: DataSource, S5: DataSource, S6: DataSource>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6) -> AnySources {
        AnySources([AnySources(s0), AnySources(s1), AnySources(s2), AnySources(s3), AnySources(s4), AnySources(s5), AnySources(s6)])
    }
    
    public static func buildBlock<S0: DataSource, S1: DataSource, S2: DataSource, S3: DataSource, S4: DataSource, S5: DataSource, S6: DataSource, S7: DataSource>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7) -> AnySources {
        AnySources([AnySources(s0), AnySources(s1), AnySources(s2), AnySources(s3), AnySources(s4), AnySources(s5), AnySources(s6), AnySources(s7)])
    }
    
    public static func buildBlock<S0: DataSource, S1: DataSource, S2: DataSource, S3: DataSource, S4: DataSource, S5: DataSource, S6: DataSource, S7: DataSource, S8: DataSource>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7, _ s8: S8) -> AnySources {
        AnySources([AnySources(s0), AnySources(s1), AnySources(s2), AnySources(s3), AnySources(s4), AnySources(s5), AnySources(s6), AnySources(s7)])
    }
    
    public static func buildBlock<S0: DataSource, S1: DataSource, S2: DataSource, S3: DataSource, S4: DataSource, S5: DataSource, S6: DataSource, S7: DataSource, S8: DataSource, S9: DataSource>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7, _ s8: S8, _ s9: S9) -> AnySources {
        AnySources([AnySources(s8), AnySources(s0), AnySources(s1), AnySources(s2), AnySources(s3), AnySources(s4), AnySources(s5), AnySources(s6), AnySources(s7), AnySources(s8), AnySources(s9)])
    }
}
