//
//  ListAdapter.swift
//  ListKit
//
//  Created by Frain on 2022/8/12.
//

// swiftlint:disable comment_spacing

public protocol ListAdapter: DataSource {
    associatedtype View = Never
    associatedtype List = DataSource

    @ListBuilder
    var list: List { get }
}

public extension ListAdapter {
    func buildList<List>(@ListBuilder list: () -> List) -> List {
        list()
    }
}

public extension ListAdapter where List == DataSource {
    var listCoordinator: ListCoordinator { list.listCoordinator }
    var listCoordinatorContext: ListCoordinatorContext { list.listCoordinatorContext }
}

public extension ListAdapter where View: ListView {
    func apply(
        by listView: View,
        animated: Bool = true,
        completion: ((Bool) -> Void)? = nil
    ) {
        (listView as? DelegateSetuptable)?.listDelegate.setCoordinator(
            context: listCoordinatorContext,
            animated: animated,
            completion: completion
        )
    }
}

@resultBuilder
public enum ListBuilder { }

public extension ListBuilder {
    static func buildPartialBlock<D: DataSource>(first: D) -> D {
        first
    }

    static func buildPartialBlock<F: DataSource, S: DataSource>(accumulated: F, next: S) -> TupleSources<F, S> {
        .init([accumulated.listCoordinatorContext, next.listCoordinatorContext])
    }

    static func buildPartialBlock<F: DataSource, S: DataSource, N: DataSource>(accumulated: TupleSources<F, S>, next: N) -> TupleSources<TupleSources<F, S>, N> {
        .init(accumulated.list + [next.listCoordinatorContext])
    }

    static func buildEither<T: DataSource, F: DataSource>(first component: T) -> ConditionalSources<T, F> {
        .init(.first(component))
    }

    static func buildEither<T: DataSource, F: DataSource>(second component: F) -> ConditionalSources<T, F> {
        .init(.second(component))
    }

    static func buildArray<D: DataSource>(_ components: [D]) -> DataSources<[D], D> {
        .init(components)
    }

    static func buildOptional<S: DataSource>(_ content: S?) -> S? {
        content
    }

    #if DEBUG
    static func buildFinalResult<S>(_ component: S) -> S {
        let input = String(describing: type(of: component))
        func formatTypeString(index: inout String.Index) -> [String] {
            var currentLevel = [""]
            var parenthesisCount = 0
            func appendChar(_ char: Character) {
                if char == " ", currentLevel.last?.isEmpty == true {
                    return
                }
                currentLevel[currentLevel.count - 1].append(char)
            }
            loop: while index != input.endIndex {
                let char = input[index]
                input.formIndex(after: &index)
                switch char {
                case "<":
                    appendChar(char)
                    if parenthesisCount == 0 {
                       let same = formatTypeString(index: &index)
                        if same.count == 1 {
                            currentLevel[currentLevel.count - 1].append("\(same.last ?? "")>")
                        } else {
                            currentLevel.append(contentsOf: same.map { "  \($0)" })
                            currentLevel.append(">")
                        }
                    }
                case ">" where currentLevel.last?.last != "-":
                    if parenthesisCount == 0 { break loop }
                    appendChar(char)
                case ",":
                    appendChar(char)
                    if parenthesisCount == 0 {
                        currentLevel.append("")
                    }
                case "(":
                    parenthesisCount += 1
                    appendChar(char)
                case ")":
                    parenthesisCount -= 1
                    appendChar(char)
                default:
                    appendChar(char)
                }
            }
            return currentLevel
        }
        var start = input.startIndex
        Log.log(formatTypeString(index: &start).joined(separator: "\n"))
        return component
    }
    #endif
}
