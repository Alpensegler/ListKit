//
//  ContextDiffableDifference.swift
//  SundayListKit
//
//  Created by Frain on 2019/6/11.
//  Copyright © 2019 Frain. All rights reserved.
//

#if iOS13
import SwiftUI
#endif

//Diffable + ElementEquatable
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Equatable, Snapshot: Identifiable, Snapshot.IdentifiedValue: Equatable, Snapshot: Equatable {
    func update(from snapshot: Snapshot) {
        if snapshot.identifiedValue != self.snapshot.identifiedValue {
            reloadCurrentContext()
            return
        }
        
        __baseUpdate(from: snapshot)
    }
}

//Diffable + ElementHashable
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Hashable, Snapshot: Identifiable, Snapshot.IdentifiedValue: Equatable, Snapshot: Equatable {
    func update(from snapshot: Snapshot) {
        if snapshot.identifiedValue != self.snapshot.identifiedValue {
            reloadCurrentContext()
            return
        }
        
        __baseUpdate(from: snapshot)
    }
}

//ElementIdentifiable
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Identifiable, Snapshot: Identifiable, Snapshot.IdentifiedValue: Equatable, Snapshot: Equatable {
    func update(from snapshot: Snapshot) {
        if snapshot.identifiedValue != self.snapshot.identifiedValue {
            reloadCurrentContext()
            return
        }
        
        __baseUpdate(from: snapshot)
    }
}

//ElementDiffable
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Identifiable, Value.Item.IdentifiedValue: Equatable, Snapshot: Identifiable, Snapshot.IdentifiedValue: Equatable, Snapshot: Equatable {
    func update(from snapshot: Snapshot) {
        if snapshot.identifiedValue != self.snapshot.identifiedValue {
            reloadCurrentContext()
            return
        }
        
        __baseUpdate(from: snapshot)
    }
}

//ElementIdentifiable + Equatable
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Identifiable, Value.Element: Equatable, Snapshot: Identifiable, Snapshot.IdentifiedValue: Equatable, Snapshot: Equatable {
    func update(from snapshot: Snapshot) {
        if snapshot.identifiedValue != self.snapshot.identifiedValue {
            reloadCurrentContext()
            return
        }
        
        __baseUpdate(from: snapshot)
    }
}

//ElementDiffable + Equatable
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Identifiable, Value.Item.IdentifiedValue: Equatable, Value.Item: Equatable, Snapshot: Identifiable, Snapshot.IdentifiedValue: Equatable, Snapshot: Equatable {
    func update(from snapshot: Snapshot) {
        if snapshot.identifiedValue != self.snapshot.identifiedValue {
            reloadCurrentContext()
            return
        }
        
        __baseUpdate(from: snapshot)
    }
}

//ElementIdentifiable + Hashable
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Identifiable, Value.Element: Hashable, Snapshot: Identifiable, Snapshot.IdentifiedValue: Equatable, Snapshot: Equatable {
    func update(from snapshot: Snapshot) {
        if snapshot.identifiedValue != self.snapshot.identifiedValue {
            reloadCurrentContext()
            return
        }
        
        __baseUpdate(from: snapshot)
    }
}

//ElementDiffable + Hashable
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Identifiable, Value.Item.IdentifiedValue: Equatable, Value.Item: Hashable, Snapshot: Identifiable, Snapshot.IdentifiedValue: Equatable, Snapshot: Equatable {
    func update(from snapshot: Snapshot) {
        if snapshot.identifiedValue != self.snapshot.identifiedValue {
            reloadCurrentContext()
            return
        }
        
        __baseUpdate(from: snapshot)
    }
}

//Section Item Diff
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Identifiable, Value.Item: Source, Snapshot: Identifiable, Snapshot.IdentifiedValue: Equatable, Snapshot: Equatable {
    func update(from snapshot: Snapshot) {
        if snapshot.identifiedValue != self.snapshot.identifiedValue {
            reloadCurrentContext()
            return
        }
        
        __baseUpdate(from: snapshot)
    }
}

//Section Item Equatable Diff
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Identifiable, Value.Item: Source, Value.Item: Equatable, Snapshot: Identifiable, Snapshot.IdentifiedValue: Equatable, Snapshot: Equatable {
    func update(from snapshot: Snapshot) {
        if snapshot.identifiedValue != self.snapshot.identifiedValue {
            reloadCurrentContext()
            return
        }
        
        __baseUpdate(from: snapshot)
    }
}

//Section Item EqualDiffable Diff
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Identifiable, Value.Item: Source, Value.Item: Equatable, Value.Item.IdentifiedValue: Equatable, Snapshot: Identifiable, Snapshot.IdentifiedValue: Equatable, Snapshot: Equatable {
    func update(from snapshot: Snapshot) {
        if snapshot.identifiedValue != self.snapshot.identifiedValue {
            reloadCurrentContext()
            return
        }
        
        __baseUpdate(from: snapshot)
    }
}



