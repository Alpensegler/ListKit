//
//  SourceBuilder.swift
//  SundayListKit iOS13
//
//  Created by Frain on 2019/6/2.
//  Copyright © 2019 Frain. All rights reserved.
//

protocol SomeP {
    var value: Int { get }
}

protocol SomeP2: SomeP {
    var p2Value: Int { get }
}

@_functionBuilder
struct SomePBuilder {
    public static func buildBlock<S0: SomeP>(_ content: S0...) -> [Int] {
        return content.map { $0.value }
    }
}

@_functionBuilder
struct SomeP2Builder {
    public static func buildBlock<S0: SomeP2>(_ content: S0...) -> [Int] {
        return content.map { $0.p2Value }
    }
}

extension Int: SomeP {
    var value: Int { return self }
}

extension Double: SomeP2 {
    var p2Value: Int {
        return Int(self)
    }
    
    var value: Int {
        return Int(self)
    }
}

func foo(@SomePBuilder build: () -> [Int]) {
    
}

func foo(@SomeP2Builder buildp2: () -> [Int]) {
    
}

@_functionBuilder
public struct SourceBuilder {
    public static func buildBlock<S0: Source>(_ content: S0) -> [AnySources<S0.Item>] {
        return [content.eraseToAnySources()]
    }
}

public extension SourceBuilder {
    static func buildIf<S0: Source>(_ content: S0?) -> [AnySources<S0.Item>] {
        return content.map { [$0.eraseToAnySources()] } ?? []
    }

    static func buildEither<S0: Source>(first: S0) -> [AnySources<S0.Item>] {
        return [first.eraseToAnySources()]
    }

    static func buildEither<S0: Source>(second: S0) -> [AnySources<S0.Item>] {
        return [second.eraseToAnySources()]
    }
}

public extension SourceBuilder {
    static func buildBlock<S0: Source, S1: Source>(_ s0: S0, _ s1: S1) -> [AnySources<S0.Item>] where S0.Item == S1.Item {
        return [
            s0.eraseToAnySources(),
            s1.eraseToAnySources(),
        ]
    }

    static func buildBlock<S0: Source, S1: Source, S2: Source>(_ s0: S0, _ s1: S1, _ s2: S2) -> [AnySources<S0.Item>] where S0.Item == S1.Item, S2.Item == S0.Item {
        return [
            s0.eraseToAnySources(),
            s1.eraseToAnySources(),
            s2.eraseToAnySources(),
        ]
    }

    func buildBlock<S0: Source, S1: Source, S2: Source, S3: Source>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3) -> [AnySources<S0.Item>] where S1.Item == S0.Item, S2.Item == S0.Item, S3.Item == S0.Item {
        return [
            s0.eraseToAnySources(),
            s1.eraseToAnySources(),
            s2.eraseToAnySources(),
            s3.eraseToAnySources(),
        ]
    }

    func buildBlock<S0: Source, S1: Source, S2: Source, S3: Source, S4: Source>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4) -> [AnySources<S0.Item>] where S1.Item == S0.Item, S2.Item == S0.Item, S3.Item == S0.Item , S4.Item == S0.Item {
        return [
            s0.eraseToAnySources(),
            s1.eraseToAnySources(),
            s2.eraseToAnySources(),
            s3.eraseToAnySources(),
            s4.eraseToAnySources(),
        ]
    }

    func buildBlock<S0: Source, S1: Source, S2: Source, S3: Source, S4: Source, S5: Source>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5) -> [AnySources<S0.Item>] where S1.Item == S0.Item, S2.Item == S0.Item, S3.Item == S0.Item , S4.Item == S0.Item, S5.Item == S0.Item {
        return [
            s0.eraseToAnySources(),
            s1.eraseToAnySources(),
            s2.eraseToAnySources(),
            s3.eraseToAnySources(),
            s4.eraseToAnySources(),
            s5.eraseToAnySources(),
        ]
    }

    func buildBlock<S0: Source, S1: Source, S2: Source, S3: Source, S4: Source, S5: Source, S6: Source>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6) -> [AnySources<S0.Item>] where S1.Item == S0.Item, S2.Item == S0.Item, S3.Item == S0.Item , S4.Item == S0.Item, S5.Item == S0.Item, S6.Item == S0.Item {
        return [
            s0.eraseToAnySources(),
            s1.eraseToAnySources(),
            s2.eraseToAnySources(),
            s3.eraseToAnySources(),
            s4.eraseToAnySources(),
            s5.eraseToAnySources(),
            s6.eraseToAnySources(),
        ]
    }

    func buildBlock<S0: Source, S1: Source, S2: Source, S3: Source, S4: Source, S5: Source, S6: Source, S7: Source>(_ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7) -> [AnySources<S0.Item>] where S1.Item == S0.Item, S2.Item == S0.Item, S3.Item == S0.Item , S4.Item == S0.Item, S5.Item == S0.Item, S6.Item == S0.Item, S7.Item == S0.Item {
        return [
            s0.eraseToAnySources(),
            s1.eraseToAnySources(),
            s2.eraseToAnySources(),
            s3.eraseToAnySources(),
            s4.eraseToAnySources(),
            s5.eraseToAnySources(),
            s6.eraseToAnySources(),
            s7.eraseToAnySources(),
        ]
    }
}

public extension Sources where SubSource == [AnySources<Item>], SourceSnapshot == Snapshot<[AnySources<Item>], Item>, UIViewType == Never {
    init(@SourceBuilder sources: () -> [AnySources<Item>]) {
        self.init(sources())
    }
}
