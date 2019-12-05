//
//  Associator.swift
//  ListKit
//
//  Created by Frain on 2019/3/27.
//

#if canImport(ObjectiveC)
import ObjectiveC.runtime

class Associator {
    enum Policy {
        case assign
        case retain
        case weak
        case copy
        
        var policy: objc_AssociationPolicy {
            switch self {
            case .assign: return .OBJC_ASSOCIATION_ASSIGN
            case .retain, .weak: return .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            case .copy: return .OBJC_ASSOCIATION_COPY
            }
        }
        
        func set<AssociatedValue>(value: AssociatedValue?) -> Any? {
            if self == .weak {
                weak var anyObject = value as AnyObject?
                return { anyObject }
            } else {
                return value
            }
        }
        
        fileprivate static func get<AssociatedValue>(from value: Any?) -> AssociatedValue? {
            value as? AssociatedValue ?? (value as? () -> AnyObject?)?() as? AssociatedValue
        }
    }
    
    static func getValue<AssociatedValue>(
        key: UnsafeRawPointer,
        from object: AnyObject
    ) -> AssociatedValue? {
        Policy.get(from: objc_getAssociatedObject(object, key))
    }
    
    static func getValue<AssociatedValue>(
        key: UnsafeRawPointer,
        from object: AnyObject,
        policy: Policy = .retain,
        initialValue: @autoclosure () -> AssociatedValue
    ) -> AssociatedValue {
        getValue(key: key, from: object) ?? {
            let value = initialValue()
            set(value: value, policy: policy, key: key, to: object)
            return value
        }()
    }
    
    static func set<AssociatedValue>(
        value: AssociatedValue?,
        policy: Policy = .retain,
        key: UnsafeRawPointer,
        to object: AnyObject
    ) {
        objc_setAssociatedObject(object, key, policy.set(value: value), policy.policy)
    }
}

#endif
