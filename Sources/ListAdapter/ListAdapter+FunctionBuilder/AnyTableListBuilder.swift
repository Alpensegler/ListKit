//
//  AnyTableListBuilder.swift
//  ListKit
//
//  Created by Frain on 2019/12/11.
//

public typealias AnyTableList<Item> = TableList<AnySource<Item>>

public protocol AnyTableListConvertible: TableListAdapter {
    init<Source: TableListAdapter>(_ dataSource: Source) where Source.SourceBase.Item == Item
}

extension TableList: AnyTableListConvertible where SourceBase: AnySourceConvertible {
    public init<Source: TableListAdapter>(_ dataSource: Source) where Item == Source.Item {
        self.init(source: SourceBase(dataSource))
    }
}

@_functionBuilder
public struct AnyTableListBuilder<AnyTableList: AnyTableListConvertible> {
    public static func buildBlock<S0: TableListAdapter>(_ s0: S0) -> [AnyTableList] where S0.Item == AnyTableList.Item {
        [AnyTableList(s0)]
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter>(_ s0: S0, _ s1: S1) -> [AnyTableList] where S0.Item == AnyTableList.Item, S1.Item == AnyTableList.Item {
        [AnyTableList(s0), AnyTableList(s1)]
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter, S2: TableListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2) -> [AnyTableList] where S0.Item == AnyTableList.Item, S1.Item == AnyTableList.Item, S2.Item == AnyTableList.Item {
        [AnyTableList(s0), AnyTableList(s1), AnyTableList(s2)]
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter, S2: TableListAdapter, S3: TableListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3) -> [AnyTableList] where S0.Item == AnyTableList.Item, S1.Item == AnyTableList.Item, S2.Item == AnyTableList.Item, S3.Item == AnyTableList.Item {
        [AnyTableList(s0), AnyTableList(s1), AnyTableList(s2), AnyTableList(s3)]
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter, S2: TableListAdapter, S3: TableListAdapter, S4: TableListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4) -> [AnyTableList] where S0.Item == AnyTableList.Item, S1.Item == AnyTableList.Item, S2.Item == AnyTableList.Item, S3.Item == AnyTableList.Item, S4.Item == AnyTableList.Item {
        [AnyTableList(s0), AnyTableList(s1), AnyTableList(s2), AnyTableList(s3), AnyTableList(s4)]
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter, S2: TableListAdapter, S3: TableListAdapter, S4: TableListAdapter, S5: TableListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5) -> [AnyTableList] where S0.Item == AnyTableList.Item, S1.Item == AnyTableList.Item, S2.Item == AnyTableList.Item, S3.Item == AnyTableList.Item, S4.Item == AnyTableList.Item, S5.Item == AnyTableList.Item {
        [AnyTableList(s0), AnyTableList(s1), AnyTableList(s2), AnyTableList(s3), AnyTableList(s4), AnyTableList(s5)]
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter, S2: TableListAdapter, S3: TableListAdapter, S4: TableListAdapter, S5: TableListAdapter, S6: TableListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6) -> [AnyTableList] where S0.Item == AnyTableList.Item, S1.Item == AnyTableList.Item, S2.Item == AnyTableList.Item, S3.Item == AnyTableList.Item, S4.Item == AnyTableList.Item, S5.Item == AnyTableList.Item, S6.Item == AnyTableList.Item {
        [AnyTableList(s0), AnyTableList(s1), AnyTableList(s2), AnyTableList(s3), AnyTableList(s4), AnyTableList(s5), AnyTableList(s6)]
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter, S2: TableListAdapter, S3: TableListAdapter, S4: TableListAdapter, S5: TableListAdapter, S6: TableListAdapter, S7: TableListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7) -> [AnyTableList] where S0.Item == AnyTableList.Item, S1.Item == AnyTableList.Item, S2.Item == AnyTableList.Item, S3.Item == AnyTableList.Item, S4.Item == AnyTableList.Item, S5.Item == AnyTableList.Item, S7.Item == AnyTableList.Item, S6.Item == AnyTableList.Item {
        [AnyTableList(s0), AnyTableList(s1), AnyTableList(s2), AnyTableList(s3), AnyTableList(s4), AnyTableList(s5), AnyTableList(s6), AnyTableList(s7)]
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter, S2: TableListAdapter, S3: TableListAdapter, S4: TableListAdapter, S5: TableListAdapter, S6: TableListAdapter, S7: TableListAdapter, S8: TableListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7, _ s8: S8) -> [AnyTableList] where S0.Item == AnyTableList.Item, S1.Item == AnyTableList.Item, S2.Item == AnyTableList.Item, S3.Item == AnyTableList.Item, S4.Item == AnyTableList.Item, S5.Item == AnyTableList.Item, S7.Item == AnyTableList.Item, S6.Item == AnyTableList.Item, S8.Item == AnyTableList.Item {
        [AnyTableList(s0), AnyTableList(s1), AnyTableList(s2), AnyTableList(s3), AnyTableList(s4), AnyTableList(s5), AnyTableList(s6), AnyTableList(s7)]
    }
    
    public static func buildBlock<S0: TableListAdapter, S1: TableListAdapter, S2: TableListAdapter, S3: TableListAdapter, S4: TableListAdapter, S5: TableListAdapter, S6: TableListAdapter, S7: TableListAdapter, S8: TableListAdapter, S9: TableListAdapter>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7, _ s8: S8, _ s9: S9) -> [AnyTableList] where S0.Item == AnyTableList.Item, S1.Item == AnyTableList.Item, S2.Item == AnyTableList.Item, S3.Item == AnyTableList.Item, S4.Item == AnyTableList.Item, S5.Item == AnyTableList.Item, S7.Item == AnyTableList.Item, S6.Item == AnyTableList.Item, S8.Item == AnyTableList.Item, S9.Item == AnyTableList.Item {
        [AnyTableList(s8), AnyTableList(s0), AnyTableList(s1), AnyTableList(s2), AnyTableList(s3), AnyTableList(s4), AnyTableList(s5), AnyTableList(s6), AnyTableList(s7), AnyTableList(s8), AnyTableList(s9)]
    }
}

public extension RangeReplaceableCollection where Element: AnyTableListConvertible {
    init(@AnyTableListBuilder<Element> content: () -> [Element]) {
        self.init(content())
    }
}
