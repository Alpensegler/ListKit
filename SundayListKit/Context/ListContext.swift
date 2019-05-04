//
//  ListContext.swift
//  SundayListKit
//
//  Created by Frain on 2019/4/16.
//  Copyright © 2019 Frain. All rights reserved.
//

#if iOS13
import SwiftUI
#endif

public struct ListContext<List: ListView, Value: Source>: Context {
    public typealias Snapshot = Value.Snapshot
    public let listView: List
    public let snapshot: Snapshot
    let listUpdater: ListUpdater<Value>
    let offset: IndexPath
    
    public var updaters: [ListUpdater<Value>] { return [listUpdater] }
    
    init(listView: List, snapshot: Snapshot) {
        self.listView = listView
        self.snapshot = snapshot
        self.offset = .default
        self.listUpdater = ListUpdater(listView: listView)
    }
    
    init(listView: List, snapshot: Snapshot, offset: IndexPath) {
        self.listView = listView
        self.snapshot = snapshot
        self.offset = offset
        self.listUpdater = ListUpdater(listView: listView, offset: offset, sectionCount: snapshot.numbersOfSections(), cellCount: snapshot.numbersOfItems(in: 0))
    }
}
