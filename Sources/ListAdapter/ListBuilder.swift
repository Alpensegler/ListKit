//
//  ListBuilder.swift
//  ListKit
//
//  Created by Frain on 2023/1/23.
//

@resultBuilder
public enum ListBuilder<View> { }

public extension ListBuilder {
    static func buildPartialBlock<D: DataSource>(first: D) -> D {
        first
    }

    static func buildPartialBlock<F: DataSource, S: DataSource>(accumulated: F, next: S) -> TupleListAdapters<F, S> {
        .init([accumulated.listCoordinatorContext, next.listCoordinatorContext])
    }

    static func buildPartialBlock<F: DataSource, S: DataSource, N: DataSource>(accumulated: TupleListAdapters<F, S>, next: N) -> TupleListAdapters<TupleListAdapters<F, S>, N> {
        .init(accumulated.contexts + [next.listCoordinatorContext])
    }

    static func buildEither<T: DataSource, F: DataSource>(first component: T) -> ConditionalListAdapters<T, F> {
        .init(.first(component))
    }

    static func buildEither<T: DataSource, F: DataSource>(second component: F) -> ConditionalListAdapters<T, F> {
        .init(.second(component))
    }

    static func buildArray<D: DataSource>(_ components: [D]) -> ListAdapters<[D]> {
        .init(components)
    }

    static func buildOptional<S: DataSource>(_ content: S?) -> S? {
        content
    }
}

public extension ListBuilder where View == Never {
    static func buildFinalResult<S: DataSource>(_ component: S) -> ListKit.List {
        Log.log(logType(of: component))
        return .init(
            listCoordinator: component.listCoordinator,
            listCoordinatorContext: component.listCoordinatorContext
        )
    }
}

public extension ListBuilder where View == Void {
    static func buildFinalResult<S>(_ component: S) -> S {
        Log.log(logType(of: component))
        return component
    }
}

extension ListBuilder {
    static func logType<S>(of component: S) -> String {
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
        return formatTypeString(index: &start).joined(separator: "\n")
    }
}
