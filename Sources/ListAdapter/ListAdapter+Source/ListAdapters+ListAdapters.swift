//
//  ListAdapters+ListAdapters.swift
//  ListKit
//
//  Created by Frain on 2019/12/13.
//

extension ScrollList: CollectionListAdapter where Source: CollectionListAdapter {
    public var collectionList: CollectionList<Source> { source.collectionList }
}

extension ScrollList: TableListAdapter where Source: TableListAdapter {
    public var tableList: TableList<Source> { source.tableList }
}

extension CollectionList: TableListAdapter where Source: TableListAdapter {
    public var tableList: TableList<Source> { source.tableList }
}

extension TableList: CollectionListAdapter where Source: CollectionListAdapter {
    public var collectionList: CollectionList<Source> { source.collectionList }
}
