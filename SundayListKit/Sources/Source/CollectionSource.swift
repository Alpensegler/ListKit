//
//  CollectionSource.swift
//  SundayListKit
//
//  Created by Frain on 2019/6/11.
//  Copyright © 2019 Frain. All rights reserved.
//

#if iOS13
import SwiftUI
#endif


public protocol CollectionSnapshot: SourceSnapshot {
    associatedtype Element
    
    var subSource: [Element] { get }
    var subSnapshots: [Any] { get }
    func element(for indexPath: IndexPath) -> Element
    func elementSnaphot(for indexPath: IndexPath) -> Any
    func elementOffset(for indexPath: IndexPath) -> IndexPath
}

public extension CollectionSnapshot where Element: Source {
    func snapshot(for indexPath: IndexPath) -> Element.Snapshot {
        return elementSnaphot(for: indexPath) as! Element.Snapshot
    }
}

public protocol CollectionSource: Source where SubSource: Collection, Snapshot: CollectionSnapshot, Snapshot.Element == Element {
    typealias Element = SubSource.Element
}

//MARK: - Collection Diff

//ElementEquatable
public extension CollectionSource where Element == Item, Item: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//ElementHashable
public extension CollectionSource where Element == Item, Item: Hashable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//ElementIdentifiable
public extension CollectionSource where Element == Item, Item: Identifiable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//ElementDiffable
public extension CollectionSource where Element == Item, Item: Identifiable, Item.IdentifiedValue: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//ElementIdentifiable + Equatable
public extension CollectionSource where Element == Item, Item: Identifiable, Item: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//ElementDiffable + Equatable
public extension CollectionSource where Element == Item, Item: Identifiable, Item.IdentifiedValue: Equatable, Item: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//ElementIdentifiable + Hashable
public extension CollectionSource where Element == Item, Item: Identifiable, Item: Hashable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//ElementDiffable + Hashable
public extension CollectionSource where Element == Item, Item: Identifiable, Item.IdentifiedValue: Equatable, Item: Hashable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//Section Item Diff
public extension CollectionSource where Element == Item, Item: Identifiable, Item: Source, Item.Snapshot == Item {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//MARK: - Equatable Collection Diff

//Equatable + ElementEquatable
public extension CollectionSource where Element == Item, Item: Equatable, Snapshot: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//Equatable + ElementHashable
public extension CollectionSource where Element == Item, Item: Hashable, Snapshot: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//Equatable + ElementIdentifiable
public extension CollectionSource where Element == Item, Item: Identifiable, Snapshot: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//Equatable + ElementDiffable
public extension CollectionSource where Element == Item, Item: Identifiable, Item.IdentifiedValue: Equatable, Snapshot: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//Equatable + ElementIdentifiable + Equatable
public extension CollectionSource where Element == Item, Item: Identifiable, Item: Equatable, Snapshot: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//Equatable + ElementDiffable + Equatable
public extension CollectionSource where Element == Item, Item: Identifiable, Item.IdentifiedValue: Equatable, Item: Equatable, Snapshot: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//Equatable + ElementIdentifiable + Hashable
public extension CollectionSource where Element == Item, Item: Identifiable, Item: Hashable, Snapshot: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//Equatable + ElementDiffable + Hashable
public extension CollectionSource where Element == Item, Item: Identifiable, Item.IdentifiedValue: Equatable, Item: Hashable, Snapshot: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//Equatable + Section Item Diff
public extension CollectionSource where Element == Item, Item: Identifiable, Item: Source, Item.Snapshot == Item, Snapshot: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//MARK: - Diffable Collection Diff

//Diffable + ElementEquatable
public extension CollectionSource where Element == Item, Item: Equatable, Snapshot: Identifiable, Snapshot.IdentifiedValue: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//Diffable + ElementHashable
public extension CollectionSource where Element == Item, Item: Hashable, Snapshot: Identifiable, Snapshot.IdentifiedValue: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//Diffable + ElementIdentifiable
public extension CollectionSource where Element == Item, Item: Identifiable, Snapshot: Identifiable, Snapshot.IdentifiedValue: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//Diffable + ElementDiffable
public extension CollectionSource where Element == Item, Item: Identifiable, Item.IdentifiedValue: Equatable, Snapshot: Identifiable, Snapshot.IdentifiedValue: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//Diffable + ElementIdentifiable + Equatable
public extension CollectionSource where Element == Item, Item: Identifiable, Item: Equatable, Snapshot: Identifiable, Snapshot.IdentifiedValue: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//Diffable + ElementDiffable + Equatable
public extension CollectionSource where Element == Item, Item: Identifiable, Item.IdentifiedValue: Equatable, Item: Equatable, Snapshot: Identifiable, Snapshot.IdentifiedValue: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//Diffable + ElementIdentifiable + Hashable
public extension CollectionSource where Element == Item, Item: Identifiable, Item: Hashable, Snapshot: Identifiable, Snapshot.IdentifiedValue: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//Diffable + ElementDiffable + Hashable
public extension CollectionSource where Element == Item, Item: Identifiable, Item.IdentifiedValue: Equatable, Item: Hashable, Snapshot: Identifiable, Snapshot.IdentifiedValue: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//Diffable + Section Item Diff
public extension CollectionSource where Element == Item, Item: Identifiable, Item: Source, Item.Snapshot == Item, Snapshot: Identifiable, Snapshot.IdentifiedValue: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//MARK: - EuqatalDiffable Collection Diff


//EquatablDiffable + ElementEquatable
public extension CollectionSource where Element == Item, Item: Equatable, Snapshot: Identifiable, Snapshot.IdentifiedValue: Equatable, Snapshot: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//EquatablDiffable + ElementHashable
public extension CollectionSource where Element == Item, Item: Hashable, Snapshot: Identifiable, Snapshot.IdentifiedValue: Equatable, Snapshot: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//EquatablDiffable + ElementIdentifiable
public extension CollectionSource where Element == Item, Item: Identifiable, Snapshot: Identifiable, Snapshot.IdentifiedValue: Equatable, Snapshot: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//EquatablDiffable + ElementDiffable
public extension CollectionSource where Element == Item, Item: Identifiable, Item.IdentifiedValue: Equatable, Snapshot: Identifiable, Snapshot.IdentifiedValue: Equatable, Snapshot: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//EquatablDiffable + ElementIdentifiable + Equatable
public extension CollectionSource where Element == Item, Item: Identifiable, Item: Equatable, Snapshot: Identifiable, Snapshot.IdentifiedValue: Equatable, Snapshot: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//EquatablDiffable + ElementDiffable + Equatable
public extension CollectionSource where Element == Item, Item: Identifiable, Item.IdentifiedValue: Equatable, Item: Equatable, Snapshot: Identifiable, Snapshot.IdentifiedValue: Equatable, Snapshot: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//EquatablDiffable + ElementIdentifiable + Hashable
public extension CollectionSource where Element == Item, Item: Identifiable, Item: Hashable, Snapshot: Identifiable, Snapshot.IdentifiedValue: Equatable, Snapshot: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//EquatablDiffable + ElementDiffable + Hashable
public extension CollectionSource where Element == Item, Item: Identifiable, Item.IdentifiedValue: Equatable, Item: Hashable, Snapshot: Identifiable, Snapshot.IdentifiedValue: Equatable, Snapshot: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

//EquatablDiffable + Section Item Diff
public extension CollectionSource where Element == Item, Item: Identifiable, Item: Source, Item.Snapshot == Item, Snapshot: Identifiable, Snapshot.IdentifiedValue: Equatable, Snapshot: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}
