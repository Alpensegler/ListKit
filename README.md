# ListKit

## 核心功能

- 无须直接调用 `performBatchUpdates(_:, completion:)` 或 `reloadData()`
- 更加现代的链式 Swift API
- 支持基于 `Result Builder` 的声明式构建写法，支持 `Flow control`
- 支持 `Property Wrapper` 形式的数据源
- **自动**根据数据模型选择更新方式 (基于 `Diff`)，且可自定义
- 一维列表支持任意 `Collection` 作为数据模型
- 创建具有多个数据类型的列表
- 支持不限于二维的复杂 `Diff`
- 支持定义缓存，可用于高度 / 大小缓存
- 支持单一数据源绑定多个 List
- 支持任何 `CollectionListLayout`
- 支持 SwiftUI
- 支持 CoreData

## 例子

除了 Readme 以外，本项目有 iOS Project，Playground，SwiftUI Preview 几种例子形式，强烈建议下载后在 ListKitExample 中查看

我们从一个简单的例子看起

``` swift
class EmojiViewModel: TableListAdapter {
    typealias Item = Character
    var source = "🥳🤭😇"
    var tableList: TableList<AdapterBase> {
        tableViewCellForRow(UITableViewCell.self) { cell, context, item in
            cell.textLabel?.text = "\(item)"
        }
    }
}
```

通过 adopt 协议 `TableListAdapter`，将 `String` 这个 `Collection` 的 `Element` —— `Charater` 指定为 `Item`，然后通过链式写法实现 `tableList` ，我们就以非常少量的代码实现了一个 `TableView` 的静态数据源

然后通过 `emojiViewModel.apply(by: tableView)` 即可将数据绑定至 UI

如果需要更新，可以 adopt 协议 `UpdatableTableListAdapter`，无需再添加任何代码就可以通过如下方法更新，通过 Diff，只会在 tableView 底部新插入两个 Cell

``` swift
emojiViewModel.source += "🧐😚"
emojiViewModel.performUpdate()
```

二维数组也支持，这个例子中还支持了点击 Cell 时打印对应数据模型

``` swift
class RoomViewModel: UpdatableTableListAdapter {
    typealias Item = Int
    var source = [[1, 2, 3], [4, 5, 6]] {
        didSet {
            performUpdate()
        }
    }
    
    var tableList: TableList<AdapterBase> {
        tableViewCellForRow(UITableViewCell.self) { cell, context, item in
            cell.textLabel?.text = "\(item)"
        }
        .tableViewDidSelectRow { (context, item) in
            print(item)
        }
    }
}
```

跨行 Diff 也同样支持，下例中通过更新会看到 3 对应的 cell 会移动到下一个 section

``` swift
roomViewModel.source = [[1, 2], [4, 5, 6, 3]]
```

非常常见的，有时需要在一个页面组合多种不同类型的数据源到一个 tableView 中，比如将上述两个例子结合

``` swift
class NestedViewModel {
    let emojiViewModel = EmojiViewModel()
    let roomViewModel = RoomViewModel()
    var shouldShowEmoji = false {
        didSet {
            performUpdate()
        }
    }
}

extension NestedViewModel: UpdatableTableListAdapter {
    typealias Item = Any
    var source: AnyTableSources {
        AnyTableSources {
            if shouldShowEmoji {
                emojiViewModel
            }
            roomViewModel
        }
    }
}
```

通过将 source 指定为 `AnyTableSources`，`Item` 指定为 `Any`，我们就能结合不同的数据源

同时，各个子 viewModel 仍能支持更新，此时不需要考虑上下文，ListKit 会自动帮你处理

``` swift
nestedViewModel.shouldShowEmoji.toggle() // 将把 emoji 显示出来
nestedViewModel.roomViewModel.source = [[1, 2], [4, 5, 6, 3]] // 将把 3 对应的 cell 移动到最后一个 section 最后
```

我们就能通过这种方式将 DataSource 解耦成多个可以单独处理相关数据的多个子 DataSource，减少复杂度，方便测试

当然，上例中的子 DataSourece 不算复杂，对这种情况我们可以用支持 `PropertyWrapper` 的自带 Sources 类型简化代码：

``` swift
class NestedViewModel {
    @Sources<String, Character> var emojis = "🥳🤭😇"
    @Sources<[[Int]], Int> var room = [[1, 2, 3], [4, 5, 6]]
    var shouldShowEmoji = false {
        didSet {
            performUpdate()
        }
    }
}

extension NestedViewModel: UpdatableTableListAdapter {
    typealias Item = Any
    var source: AnyTableSources {
        AnyTableSources {
            if shouldShowEmoji {
                $emojis
                    .tableViewCellForRow(UITableViewCell.self) { cell, context, item in
                        cell.textLabel?.text = "\(item)"
                    }
            }
            $room
                .tableViewCellForRow(UITableViewCell.self) { cell, context, item in
                    cell.textLabel?.text = "\(item)"
                }
                .tableViewDidSelectRow { (context, item) in
                    print(item)
                }
        }
    }
}

nestedViewModel.shouldShowEmoji.toggle() // 将把 emoji 显示出来
nestedViewModel.room = [[1, 2], [4, 5, 6, 3]] // 将把 3 对应的 cell 移动到最后一个 section 最后

```
