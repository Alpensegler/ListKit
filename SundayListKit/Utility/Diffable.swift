//
//  Diffable.swift
//  SundayListKit
//
//  Created by Frain on 2019/3/24.
//  Copyright © 2019 Frain. All rights reserved.
//

#if iOS13
import SwiftUI
#endif

public typealias Diffable = Equatable & Identifiable

public protocol EquatablesCollection: Collection where Element: Equatable { }
public protocol HashablesCollection: Collection where Element: Hashable { }
public protocol IdentifiablesCollection: Collection where Element: Identifiable { }
public protocol DiffablesCollection: Collection where Element: Identifiable, Element.IdentifiedValue: Equatable { }

public protocol DiffableDatas: IdentifiablesCollection where Element: ListData { }
public protocol DiffableDataSources: DiffableDatas where Element: DataSource { }
