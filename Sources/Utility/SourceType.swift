//
//  SourceType.swift
//  ListKit
//
//  Created by Frain on 2020/9/14.
//

enum SourceType {
    case section
    case sectionModels
    case models

    var isSection: Bool { self == .section || self == .sectionModels }
    var isModels: Bool { self == .models || self == .sectionModels }
}
