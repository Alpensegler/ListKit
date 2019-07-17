//
//  Source+Array.swift
//  SundayListKit
//
//  Created by Frain on 2019/8/7.
//  Copyright © 2019 Frain. All rights reserved.
//

extension Array: Source where Element: Source {
    public typealias Item = Element.Item
    public typealias SourceSnapshot = Snapshot<[Element], Item>
    
    public var source: [Element] {
        return self
    }
    
    public func update(context: UpdateContext<Snapshot<[Element], Element.Item>>) {
        context.reloadCurrent()
    }
}

public extension Array where Element: Source, Element: Identifiable {
    func update(context: UpdateContext<Snapshot<[Element], Element.Item>>) {
        context.diffUpdate()
    }
}

public extension Array where Element: Source, Element: Diffable {
    func update(context: UpdateContext<Snapshot<[Element], Element.Item>>) {
        context.diffUpdate()
    }
}

extension Array: Identifiable where Element: Identifiable {
    public var id: Element.ID? {
        return first?.id
    }
}
