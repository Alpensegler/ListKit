//
//  ListCoordinatorContext.swift
//  ListKit
//
//  Created by Frain on 2020/6/8.
//

import Foundation

public struct ListCoordinatorContext {
    weak var storage: CoordinatorStorage?
    var coordinator: ListCoordinator
    var count: Count

    var selectors = Set<Selector>()
    var functions = [Selector: Any]()

    var section = (sectioned: false, removeEmpty: false) {
        didSet {
            if section == oldValue { return }
            count = reconfigCount()
        }
    }

    var index = 0

    init(coordinator: ListCoordinator) {
        self.coordinator = coordinator
        selectors = coordinator.selectors ?? .init()
        count = coordinator.count
    }

    func reconfigCount() -> Count {
        var count = coordinator.count
        switch (count, section.sectioned) {
        case (let .items(itemCount), true):
            count = .sections(nil, itemCount == 0 && section.removeEmpty ? [] : [itemCount ?? 0], nil)
        case (let .items(itemCount), false):
            count = .items(itemCount == 0 && section.removeEmpty ? nil : itemCount)
        case (.sections(let pre, var sections, let next), true):
            if section.removeEmpty { sections = sections.filter { $0 == 0 } }
            pre.map { count in if count != 0 || !section.removeEmpty { sections.insert(count, at: 0) } }
            next.map { count in if count != 0 || !section.removeEmpty { sections.append(count) } }
            count = .sections(nil, sections, nil)
        case (var .sections(pre, sections, next), false) where section.removeEmpty:
            sections = sections.filter { $0 == 0 }
            if pre == 0 { pre = nil }
            if next == 0 { next = nil }
            count = .sections(pre, sections, next)
        default:
            break
        }
        return count
    }
}
