//
//  ListCoordinatorContext.swift
//  ListKit
//
//  Created by Frain on 2020/6/8.
//

import Foundation

public struct ListCoordinatorContext {
    enum ContextCount: Equatable {
        enum EmptySectionStyle: Equatable {
            case remove(mapping: [Int]?)
            case keep
        }

        case coordinatorCount
        case sectioned([Int], style: EmptySectionStyle)
    }

    weak var storage: CoordinatorStorage?
    var coordinator: ListCoordinator
    var count = ContextCount.coordinatorCount

    var selectors = Set<Selector>()
    var functions = [Selector: Any]()
    var coordinatorCount: Count {
        switch count {
        case .coordinatorCount: return coordinator.count
        case let .sectioned(sections, _): return .sections(nil, sections, nil)
        }
    }
    
    var sections: [Int] {
        guard case let .sectioned(sections, _) = count else {
            fatalError("should config section for once")
        }
        return sections
    }

    init(coordinator: ListCoordinator) {
        self.coordinator = coordinator
        selectors = coordinator.selectors ?? .init()
    }

    mutating func reconfigCount() {
        switch count {
        case .coordinatorCount: break
        case .sectioned(_, style: let style): _configSectioned(style != .keep)
        }
    }

    mutating func configSectioned(_ removeEmptySection: Bool = false) {
        switch (count, removeEmptySection) {
        case (.sectioned(_, .keep), false), (.sectioned(_, .remove), _): return
        default: _configSectioned(removeEmptySection)
        }
    }
}

extension ListCoordinatorContext {
    func apply<Input, Output>(
        _ selector: Selector,
        view: AnyObject,
        with input: Input
    ) -> Output? {
        coordinator.apply(selector, for: self, view: view, with: input)
    }

    func apply<Input, Output, Index: ListKit.Index>(
        _ selector: Selector,
        view: AnyObject,
        with input: Input,
        index: Index,
        _ rawIndex: Index
    ) -> Output? {
        var index = index
        if case let .sectioned(_, .remove(mapping?)) = count {
            index.section = mapping[index.section]
        }
        return coordinator.apply(selector, for: self, view: view, with: input, index: index, rawIndex)
    }
}

private extension ListCoordinatorContext {
    mutating func _configSectioned(_ removeEmptySection: Bool) {
        switch coordinator.count {
        case let .items(count):
            self.count = .sectioned(
                count ?? 0 == 0 && removeEmptySection ? [] : [count ?? 0],
                style: removeEmptySection ? .remove(mapping: nil) : .keep
            )
        case .sections(let pre, var section, let next):
            if let pre = pre { section.insert(pre, at: 0) }
            if let next = next { section.append(next) }
            var mapping: [Int]?
            if removeEmptySection, section.contains(0) {
                mapping = section.enumerated().compactMap {
                    $0.element == 0 ? nil : $0.offset
                }
                section = section.filter { $0 != 0 }
            }
            self.count = .sectioned(
                section,
                style: removeEmptySection ? .remove(mapping: mapping) : .keep
            )
        }
    }
}
