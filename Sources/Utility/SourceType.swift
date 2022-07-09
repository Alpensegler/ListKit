//
//  SourceType.swift
//  ListKit
//
//  Created by Frain on 2020/9/14.
//

enum SourceType {
    case section
    case sectionItems
    case items

    var isSection: Bool { self == .section || self == .sectionItems }
    var isItems: Bool { self == .items || self == .sectionItems }
}
