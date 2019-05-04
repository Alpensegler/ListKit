//
//  Context.swift
//  SundayListKit
//
//  Created by Frain on 2019/6/9.
//  Copyright © 2019 Frain. All rights reserved.
//

#if iOS13
import SwiftUI
#endif

public protocol Context: Updater where Value: Source {
    associatedtype List: ListView
    typealias Snapshot = Value.Snapshot
    
    var listView: List { get }
    var snapshot: Snapshot { get }
}

//Equatable
public extension Context where Snapshot: Equatable {
    func update(from snapshot: Snapshot) {
        if snapshot != self.snapshot {
            reloadCurrentContext()
        }
    }
}

//Diffable
public extension Context where Snapshot: Identifiable, Snapshot.IdentifiedValue: Equatable {
    func update(from snapshot: Snapshot) {
        if snapshot.identifiedValue != self.snapshot.identifiedValue {
            reloadCurrentContext()
        }
    }
}

//Equatable + Diffable
public extension Context where Snapshot: Identifiable, Snapshot: Equatable, Snapshot.IdentifiedValue: Equatable {
    func update(from snapshot: Snapshot) {
        if snapshot.identifiedValue != self.snapshot.identifiedValue {
            reloadCurrentContext()
        }
    }
}
