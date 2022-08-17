//
//  AnyListSourcesBuilder.swift
//  ListKit
//
//  Created by Frain on 2022/8/17.
//

// swiftlint:disable line_length function_parameter_count

public typealias AnyListSources<View: ListView> = ListAdaptation<AnySources, View>
public typealias AnyTableSources = AnyListSources<TableView>
public typealias AnyCollectionSources = AnyListSources<CollectionView>

public extension ListAdaptation where Source == AnySources {
    init<Source: ListAdapter>(
        options: ListOptions = .init(),
        @AnyListSourcesBuilder<View> content: () -> Source
    ) where Source.View == View {
        self.init(content(), options: options)
    }
}

@resultBuilder
public struct AnyListSourcesBuilder<View: ListView> {
    public static func buildIf<S: ListAdapter>(_ content: S?) -> S? where S.View == View {
        content
    }

    public static func buildEither<TrueContent, FalseContent>(
        first: TrueContent
    ) -> ConditionalSources<TrueContent, FalseContent>
    where TrueContent: ListAdapter, FalseContent: ListAdapter, TrueContent.View == View, FalseContent.View == View {
        .trueContent(first)
    }

    public static func buildEither<TrueContent, FalseContent>(
        second: FalseContent
    ) -> ConditionalSources<TrueContent, FalseContent>
    where TrueContent: ListAdapter, FalseContent: ListAdapter, TrueContent.View == View, FalseContent.View == View {
        .falseContent(second)
    }

    public static func buildBlock<S: ListAdapter>(_ content: S) -> S where S.View == View {
        content
    }

    public static func buildBlock<S0: ListAdapter, S1: ListAdapter>(_ s0: S0, _ s1: S1) -> ListAdaptation<Sources<[AnyListSources<View>], Any>, View> where S0.View == View, S1.View == View {
        ListAdaptation(Sources(dataSources: [.init(s0), .init(s1)]))
    }

    public static func buildBlock<S0: ListAdapter, S1: ListAdapter, S2: ListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2) -> ListAdaptation<Sources<[AnyListSources<View>], Any>, View> where S0.View == View, S1.View == View, S2.View == View {
        ListAdaptation(Sources(dataSources: [.init(s0), .init(s1), .init(s2)]))
    }

    public static func buildBlock<S0: ListAdapter, S1: ListAdapter, S2: ListAdapter, S3: ListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3) -> ListAdaptation<Sources<[AnyListSources<View>], Any>, View> where S0.View == View, S1.View == View, S2.View == View, S3.View == View {
        ListAdaptation(Sources(dataSources: [.init(s0), .init(s1), .init(s2), .init(s3)]))
    }

    public static func buildBlock<S0: ListAdapter, S1: ListAdapter, S2: ListAdapter, S3: ListAdapter, S4: ListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4) -> ListAdaptation<Sources<[AnyListSources<View>], Any>, View> where S0.View == View, S1.View == View, S2.View == View, S3.View == View, S4.View == View {
        ListAdaptation(Sources(dataSources: [.init(s0), .init(s1), .init(s2), .init(s3), .init(s4)]))
    }

    public static func buildBlock<S0: ListAdapter, S1: ListAdapter, S2: ListAdapter, S3: ListAdapter, S4: ListAdapter, S5: ListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5) -> ListAdaptation<Sources<[AnyListSources<View>], Any>, View> where S0.View == View, S1.View == View, S2.View == View, S3.View == View, S4.View == View, S5.View == View {
        ListAdaptation(Sources(dataSources: [.init(s0), .init(s1), .init(s2), .init(s3), .init(s4), .init(s5)]))
    }

    public static func buildBlock<S0: ListAdapter, S1: ListAdapter, S2: ListAdapter, S3: ListAdapter, S4: ListAdapter, S5: ListAdapter, S6: ListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6) -> ListAdaptation<Sources<[AnyListSources<View>], Any>, View> where S0.View == View, S1.View == View, S2.View == View, S3.View == View, S4.View == View, S5.View == View, S6.View == View {
        ListAdaptation(Sources(dataSources: [.init(s0), .init(s1), .init(s2), .init(s3), .init(s4), .init(s5), .init(s6)]))
    }

    public static func buildBlock<S0: ListAdapter, S1: ListAdapter, S2: ListAdapter, S3: ListAdapter, S4: ListAdapter, S5: ListAdapter, S6: ListAdapter, S7: ListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7) -> ListAdaptation<Sources<[AnyListSources<View>], Any>, View> where S0.View == View, S1.View == View, S2.View == View, S3.View == View, S4.View == View, S5.View == View, S6.View == View, S7.View == View {
        ListAdaptation(Sources(dataSources: [.init(s0), .init(s1), .init(s2), .init(s3), .init(s4), .init(s5), .init(s6), .init(s7)]))
    }

    public static func buildBlock<S0: ListAdapter, S1: ListAdapter, S2: ListAdapter, S3: ListAdapter, S4: ListAdapter, S5: ListAdapter, S6: ListAdapter, S7: ListAdapter, S8: ListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7, _ s8: S8) -> ListAdaptation<Sources<[AnyListSources<View>], Any>, View> where S0.View == View, S1.View == View, S2.View == View, S3.View == View, S4.View == View, S5.View == View, S6.View == View, S7.View == View, S8.View == View {
        ListAdaptation(Sources(dataSources: [.init(s0), .init(s1), .init(s2), .init(s3), .init(s4), .init(s5), .init(s6), .init(s7), .init(s8)]))
    }

    public static func buildBlock<S0: ListAdapter, S1: ListAdapter, S2: ListAdapter, S3: ListAdapter, S4: ListAdapter, S5: ListAdapter, S6: ListAdapter, S7: ListAdapter, S8: ListAdapter, S9: ListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7, _ s8: S8, _ s9: S9) -> ListAdaptation<Sources<[AnyListSources<View>], Any>, View> where S0.View == View, S1.View == View, S2.View == View, S3.View == View, S4.View == View, S5.View == View, S6.View == View, S7.View == View, S8.View == View, S9.View == View {
        ListAdaptation(Sources(dataSources: [.init(s0), .init(s1), .init(s2), .init(s3), .init(s4), .init(s5), .init(s6), .init(s7), .init(s8), .init(s9)]))
    }
}
