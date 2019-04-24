//
//  Associator.swift
//  SundayListKit
//
//  Created by Frain on 2019/3/27.
//  Copyright © 2019 Frain. All rights reserved.
//

import ObjectiveC.runtime

class Associator {
    
    enum Policy {
        case assign
        case retain
        case weak
        case copy
        
        fileprivate var policy: objc_AssociationPolicy {
            switch self {
            case .assign:
                return .OBJC_ASSOCIATION_ASSIGN
            case .retain, .weak:
                return .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            case .copy:
                return .OBJC_ASSOCIATION_COPY
            }
        }
        
        fileprivate func set<AssociatedValue>(value: AssociatedValue?) -> Any? {
            if self == .weak {
                weak var anyObject = value as AnyObject?
                return { anyObject }
            } else {
                return value
            }
        }
        
        fileprivate static func get<AssociatedValue>(from value: Any?) -> AssociatedValue? {
            return value as? AssociatedValue ?? (value as? () -> AnyObject?)?() as? AssociatedValue
        }
    }
    
    static func getValue<AssociatedValue>(key: UnsafeRawPointer, from object: AnyObject) -> AssociatedValue? {
        return Policy.get(from: objc_getAssociatedObject(object, key))
    }
    
    static func getValue<AssociatedValue>(key: UnsafeRawPointer, from object: AnyObject, policy: Policy = .retain, initialValue: @autoclosure () -> AssociatedValue) -> AssociatedValue {
        return getValue(key: key, from: object) ?? {
            let value = initialValue()
            set(value: value, policy: policy, key: key, to: object)
            return value
        }()
    }
    
    static func set<AssociatedValue>(value: AssociatedValue?, policy: Policy = .retain, key: UnsafeRawPointer, to object: AnyObject) {
        objc_setAssociatedObject(object, key, policy.set(value: value), policy.policy)
    }
}
