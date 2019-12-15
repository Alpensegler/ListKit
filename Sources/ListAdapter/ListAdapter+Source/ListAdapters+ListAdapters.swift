//
//  ListAdapters+ListAdapters.swift
//  ListKit
//
//  Created by Frain on 2019/12/13.
//

extension ScrollList: CollectionListAdapter where Source: CollectionListAdapter {
    public var collectionList: CollectionList<Source> { .init(self) }
}

extension ScrollList: TableListAdapter where Source: TableListAdapter {
    public var tableList: TableList<Source> { .init(self) }
}

extension CollectionList: TableListAdapter where Source: TableListAdapter {
    public var tableList: TableList<Source> { .init(self) }
}

extension TableList: CollectionListAdapter where Source: CollectionListAdapter {
    public var collectionList: CollectionList<Source> { .init(self) }
}
