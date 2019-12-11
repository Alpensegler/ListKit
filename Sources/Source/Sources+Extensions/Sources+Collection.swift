//
//  Sources+Collection.swift
//  ListKit
//
//  Created by Frain on 2019/12/12.
//

public extension Collection {
    func asDataSource(
        id: AnyHashable,
        updater: Updater<Sources<Self, Element>> = .none
    ) -> Sources<Self, Element> {
        .init(id: id, items: self, updater: updater)
    }
    
    func asDataSource(updater: Updater<Sources<Self, Element>> = .none) -> Sources<Self, Element> {
        .init(items: self, updater: updater)
    }
}

public extension RangeReplaceableCollection {
    func asDataSource(
        id: AnyHashable,
        updater: Updater<Sources<Self, Element>> = .none
    ) -> Sources<Self, Element> {
        .init(id: id, items: self, updater: updater)
    }
    
    func asDataSource(updater: Updater<Sources<Self, Element>> = .none) -> Sources<Self, Element> {
        .init(items: self, updater: updater)
    }
}

public extension Collection where Element: Collection {
    func asDataSource(
        id: AnyHashable,
        updater: Updater<Sources<Self, Element.Element>> = .none
    ) -> Sources<Self, Element.Element> {
        .init(id: id, sections: self, updater: updater)
    }
    
    func asDataSource(
        updater: Updater<Sources<Self, Element.Element>> = .none
    ) -> Sources<Self, Element.Element> {
        .init(sections: self, updater: updater)
    }
}

public extension RangeReplaceableCollection where Element: RangeReplaceableCollection {
    func asDataSource(
        id: AnyHashable,
        updater: Updater<Sources<Self, Element.Element>> = .none
    ) -> Sources<Self, Element.Element> {
        .init(id: id, sections: self, updater: updater)
    }
    
    func asDataSource(
        updater: Updater<Sources<Self, Element.Element>> = .none
    ) -> Sources<Self, Element.Element> {
        .init(sections: self, updater: updater)
    }
}
