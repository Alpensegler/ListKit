//
//  Identifiable.swift
//  SundayListKit
//
//  Created by Frain on 2019/6/23.
//  Copyright © 2019 Frain. All rights reserved.
//

/// A type that can be compared for identity equality.
public protocol Identifiable {
    
    /// A type of unique identifier that can be compared for equality.
    associatedtype ID: Hashable
    
    /// A unique identifier that can be compared for equality.
    var id: Self.ID { get }
}

extension Identifiable where Self: AnyObject {
    
    @inlinable public var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}
