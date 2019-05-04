//
//  ContextEquatableDifference.swift
//  SundayListKit
//
//  Created by Frain on 2019/6/11.
//  Copyright © 2019 Frain. All rights reserved.
//

#if iOS13
import SwiftUI
#endif

//Equatable + ElementEquatable
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Equatable, Snapshot: Equatable {
    func update(from snapshot: Snapshot) {
        if snapshot != self.snapshot {
            reloadCurrentContext()
            return
        }
        
        __baseUpdate(from: snapshot)
    }
}

//Equatable + ElementHashable
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Hashable, Snapshot: Equatable {
    func update(from snapshot: Snapshot) {
        if snapshot != self.snapshot {
            reloadCurrentContext()
            return
        }
        
        __baseUpdate(from: snapshot)
    }
}

//ElementIdentifiable
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Identifiable, Snapshot: Equatable {
    func update(from snapshot: Snapshot) {
        if snapshot != self.snapshot {
            reloadCurrentContext()
            return
        }
        
        __baseUpdate(from: snapshot)
    }
}

//ElementDiffable
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Identifiable, Value.Item.IdentifiedValue: Equatable, Snapshot: Equatable {
    func update(from snapshot: Snapshot) {
        if snapshot != self.snapshot {
            reloadCurrentContext()
            return
        }
        
        __baseUpdate(from: snapshot)
    }
}

//ElementIdentifiable + Equatable
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Identifiable, Value.Element: Equatable, Snapshot: Equatable {
    func update(from snapshot: Snapshot) {
        if snapshot != self.snapshot {
            reloadCurrentContext()
            return
        }
        
        __baseUpdate(from: snapshot)
    }
}

//ElementDiffable + Equatable
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Identifiable, Value.Item.IdentifiedValue: Equatable, Value.Item: Equatable, Snapshot: Equatable {
    
    func update(from snapshot: Snapshot) {
        if snapshot != self.snapshot {
            reloadCurrentContext()
            return
        }
        
        __baseUpdate(from: snapshot)
    }
}

//ElementIdentifiable + Hashable
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Identifiable, Value.Element: Hashable, Snapshot: Equatable {
    
    func update(from snapshot: Snapshot) {
        if snapshot != self.snapshot {
            reloadCurrentContext()
            return
        }
        
        __baseUpdate(from: snapshot)
    }
}

//ElementDiffable + Hashable
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Identifiable, Value.Item.IdentifiedValue: Equatable, Value.Item: Hashable, Snapshot: Equatable {
    
    func update(from snapshot: Snapshot) {
        if snapshot != self.snapshot {
            reloadCurrentContext()
            return
        }
        
        __baseUpdate(from: snapshot)
    }
}

//Section Item Diff
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Identifiable, Value.Item: Source, Snapshot: Equatable {
    func update(from snapshot: Snapshot) {
        if snapshot != self.snapshot {
            reloadCurrentContext()
            return
        }
        
        __baseUpdate(from: snapshot)
    }
}

//Section Item Equatable Diff
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Identifiable, Value.Item: Source, Value.Item: Equatable, Snapshot: Equatable {
    func update(from snapshot: Snapshot) {
        if snapshot != self.snapshot {
            reloadCurrentContext()
            return
        }
        
        __baseUpdate(from: snapshot)
    }
}

//Section Item EqualDiffable Diff
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Identifiable, Value.Item: Source, Value.Item: Equatable, Value.Item.IdentifiedValue: Equatable, Snapshot: Equatable {
    func update(from snapshot: Snapshot) {
        if snapshot != self.snapshot {
            reloadCurrentContext()
            return
        }
        
        __baseUpdate(from: snapshot)
    }
}

