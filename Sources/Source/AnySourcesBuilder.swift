//
//  AnySourcesBuilder.swift
//  ListKit
//
//  Created by Frain on 2019/12/11.
//

// swiftlint:disable line_length function_parameter_count

public extension AnySources {
    init<Source: DataSource>(
        options: ListOptions = .init(),
        @AnySourcesBuilder content: () -> Source
    ) {
        self.init(content(), options: options)
    }
}

@resultBuilder
public struct AnySourcesBuilder {
    public static func buildIf<S: DataSource>(_ content: S?) -> S? {
        content
    }

    public static func buildEither<TrueContent, FalseContent>(
        trueContent: TrueContent
    ) -> ConditionalSources<TrueContent, FalseContent>
    where TrueContent: DataSource, FalseContent: DataSource {
        .trueContent(trueContent)
    }

    public static func buildEither<TrueContent, FalseContent>(
        falseContent: FalseContent
    ) -> ConditionalSources<TrueContent, FalseContent>
    where TrueContent: DataSource, FalseContent: DataSource {
        .falseContent(falseContent)
    }

    public static func buildBlock<S: DataSource>(_ content: S) -> S {
        content
    }

    public static func buildBlock<S0: DataSource, S1: DataSource>(_ s0: S0, _ s1: S1) -> Sources<[AnySources], Any> {
        Sources(dataSources: [AnySources(s0), AnySources(s1)])
    }

    public static func buildBlock<S0: DataSource, S1: DataSource, S2: DataSource>(_ s0: S0, _ s1: S1, _ s2: S2) -> Sources<[AnySources], Any> {
        Sources(dataSources: [AnySources(s0), AnySources(s1), AnySources(s2)])
    }

    public static func buildBlock<S0: DataSource, S1: DataSource, S2: DataSource, S3: DataSource>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3) -> Sources<[AnySources], Any> {
        Sources(dataSources: [AnySources(s0), AnySources(s1), AnySources(s2), AnySources(s3)])
    }

    public static func buildBlock<S0: DataSource, S1: DataSource, S2: DataSource, S3: DataSource, S4: DataSource>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4) -> Sources<[AnySources], Any> {
        Sources(dataSources: [AnySources(s0), AnySources(s1), AnySources(s2), AnySources(s3), AnySources(s4)])
    }

    public static func buildBlock<S0: DataSource, S1: DataSource, S2: DataSource, S3: DataSource, S4: DataSource, S5: DataSource>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5) -> Sources<[AnySources], Any> {
        Sources(dataSources: [AnySources(s0), AnySources(s1), AnySources(s2), AnySources(s3), AnySources(s4), AnySources(s5)])
    }

    public static func buildBlock<S0: DataSource, S1: DataSource, S2: DataSource, S3: DataSource, S4: DataSource, S5: DataSource, S6: DataSource>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6) -> Sources<[AnySources], Any> {
        Sources(dataSources: [AnySources(s0), AnySources(s1), AnySources(s2), AnySources(s3), AnySources(s4), AnySources(s5), AnySources(s6)])
    }

    public static func buildBlock<S0: DataSource, S1: DataSource, S2: DataSource, S3: DataSource, S4: DataSource, S5: DataSource, S6: DataSource, S7: DataSource>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7) -> Sources<[AnySources], Any> {
        Sources(dataSources: [AnySources(s0), AnySources(s1), AnySources(s2), AnySources(s3), AnySources(s4), AnySources(s5), AnySources(s6), AnySources(s7)])
    }

    public static func buildBlock<S0: DataSource, S1: DataSource, S2: DataSource, S3: DataSource, S4: DataSource, S5: DataSource, S6: DataSource, S7: DataSource, S8: DataSource>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7, _ s8: S8) -> Sources<[AnySources], Any> {
        Sources(dataSources: [AnySources(s0), AnySources(s1), AnySources(s2), AnySources(s3), AnySources(s4), AnySources(s5), AnySources(s6), AnySources(s7)])
    }

    public static func buildBlock<S0: DataSource, S1: DataSource, S2: DataSource, S3: DataSource, S4: DataSource, S5: DataSource, S6: DataSource, S7: DataSource, S8: DataSource, S9: DataSource>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7, _ s8: S8, _ s9: S9) -> Sources<[AnySources], Any> {
        Sources(dataSources: [AnySources(s8), AnySources(s0), AnySources(s1), AnySources(s2), AnySources(s3), AnySources(s4), AnySources(s5), AnySources(s6), AnySources(s7), AnySources(s8), AnySources(s9)])
    }
}
